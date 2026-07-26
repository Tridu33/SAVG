#!/bin/bash
#
# bash tests/test_full.sh — execute all domains default pipeline
# bash tests/test_full.sh -domain TreeChop — only execute TreeChop one domain.
# 
# For each domain the script executes the three-step pipeline documented in
# the README:
#   1. ./RunPRPForCurDomain.sh <domain>   (PRP solver + policy translation)
#   2. ./PrintHuman_Policy.sh <domain>    (re-translate policy to human format)
#   3. python ./DrawDotPolicy.py -domainname <domain>  (render policy graph)
#
# Prerequisites handled automatically:
#   • Python 3 virtual environment created with uv (.venv at workspace root)
#   • dot (Graphviz)   — required by DrawDotPolicy.py
#   • /usr/bin/time    — used by PRP solver
#   • PRP solver binaries (Linux ELF builds of src/preprocess/preprocess and
#     src/search/downward-release)
#
# Cross-platform notes (vs the original macOS-only script):
#   • Replaces `gtime` (GNU-time via MacPorts) with /usr/bin/time.
#   • Skips the macOS-only "ELF → reject" gate on Linux (binaries are ELF).
#   • Uses apt-get for graphviz when missing.
#   • Lets uv pick the system Python (no hard 3.12 pin) so it works on any
#     distro that ships uv.

set -u

# ---------------------------------------------------------------------------
# Paths (derived from script location so it stays portable)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAVG_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PRP_DIR="$SAVG_ROOT/PRP_planner-for-relevant-policies"
CPS2FOND_DIR="$SAVG_ROOT/cps2FondandVerify"
VENV_DIR="$SAVG_ROOT/.venv"

# ---------------------------------------------------------------------------
# 10 original domains from usage_README.md (lines 5-43 and 78-80)
# + 6 new domains generated via cps2FondandVerify/main.py
#   (TreeChop, NestedVar, Snow, DeliveryFuel, TrashCollection,
#    35bottle4Lwater)
# ---------------------------------------------------------------------------
DOMAINS=(
    blocks_clear
    llvisitall
    reversell
    stripedtower
    RGBBlocks
    treetraversal
    TreeChop
    NestedVar
    Snow
    # DeliveryFuel
    TrashCollection
)

# Domain→CPN mapping used by cps2FondandVerify/main.py
# (cpn = number of classical plans for each domain)
declare -A DOMAIN_CPN=(
    ["blocks_clear"]=1
    ["llvisitall"]=3
    ["reversell"]=1
    ["stripedtower"]=4
    ["treetraversal"]=4
    ["RGBBlocks"]=4
    ["TreeChop"]=2
    ["NestedVar"]=1
    ["Snow"]=1
    ["TrashCollection"]=1
    # ["DeliveryFuel"]=3
)

# ---------------------------------------------------------------------------
# Domain display names for the summary table
# ---------------------------------------------------------------------------
declare -A DOMAIN_DISPLAY=(
    ["blocks_clear"]="ClearA"
    ["llvisitall"]="Visitall"
    ["reversell"]="ReverseLL"
    ["stripedtower"]="Striped"
    ["RGBBlocks"]="RGBBlocks"
    ["treetraversal"]="TreeTraverse"
    ["TreeChop"]="TreeChop"
    ["NestedVar"]="NestVar"
    ["Snow"]="Snow"
    # ["DeliveryFuel"]="Delivery"
    ["TrashCollection"]="Trash"
)

# ---------------------------------------------------------------------------
# Statistics arrays for summary table
#   I  = instance count  (from DOMAIN_CPN)
#   V  = predicate count (from fond_*_d.pddl)
#   T_g = generation time (ms)
#   T_v = verification time (ms)
#   π  = policy size  ("If holds" count in human_policy.out)
#
# Stats are stored via dynamic export variables:
#   STATS_I_<domain>, STATS_V_<domain>, STATS_TG_<domain>,
#   STATS_TV_<domain>, STATS_PI_<domain>
# ---------------------------------------------------------------------------
STATS_ORDER=()          # ordered list of processed domains

# ---------------------------------------------------------------------------
# Colour helpers (disabled when stdout is not a TTY)
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; CYAN=''; NC=''
fi

PASS=0; SKIP=0; FAIL=0
FAILED_DOMAINS=()

# ---------------------------------------------------------------------------
# Detect platform (used to skip macOS-only checks on Linux)
# ---------------------------------------------------------------------------
detect_platform() {
    case "$(uname -s)" in
        Darwin)  echo "macos" ;;
        Linux)   echo "linux" ;;
        *)       echo "other" ;;
    esac
}
PLATFORM="$(detect_platform)"

# ---------------------------------------------------------------------------
# Step 1 — create / activate the uv-managed .venv
# ---------------------------------------------------------------------------
setup_venv() {
    echo -e "${CYAN}=== [1/7] Setting up Python virtual environment (uv) ===${NC}"
    if [ ! -d "$VENV_DIR" ]; then
        echo "  Creating .venv with uv ..."
        (cd "$SAVG_ROOT" && uv venv .venv) || {
            echo -e "${RED}ERROR: uv venv failed${NC}"
            exit 1
        }
    else
        echo "  .venv already exists: $VENV_DIR"
    fi
    # shellcheck disable=SC1091
    source "$VENV_DIR/bin/activate"
    echo "  Python: $(python --version 2>&1)  ($VENV_DIR/bin/python)"
}

# ---------------------------------------------------------------------------
# Step 2 — verify system tools (/usr/bin/time, dot)
# ---------------------------------------------------------------------------
check_dependencies() {
    echo -e "${CYAN}=== [2/7] Checking system dependencies ===${NC}"

    if ! command -v /usr/bin/time >/dev/null 2>&1; then
        echo "  /usr/bin/time not found — installing 'time' via apt-get ..."
        apt-get install -y time || { echo -e "${RED}ERROR: apt-get install time failed${NC}"; exit 1; }
    fi
    echo "  time : $(command -v /usr/bin/time)"

    if ! command -v dot >/dev/null 2>&1; then
        echo "  dot not found — installing graphviz via apt-get ..."
        apt-get install -y graphviz || { echo -e "${RED}ERROR: apt-get install graphviz failed${NC}"; exit 1; }
    fi
    echo "  dot   : $(command -v dot)"
}

# ---------------------------------------------------------------------------
# Step 3 — verify PRP solver binaries exist and are usable on this platform
# ---------------------------------------------------------------------------
verify_binaries() {
    echo -e "${CYAN}=== [3/7] Verifying PRP solver binaries ===${NC}"

    local bins=(
        "$PRP_DIR/src/preprocess/preprocess"
        "$PRP_DIR/src/search/downward-release"
    )
    for bin in "${bins[@]}"; do
        if [ ! -f "$bin" ]; then
            echo -e "${RED}ERROR: missing binary: $bin${NC}"
            echo "  Rebuild with: cd '$PRP_DIR/src' && ./build_all"
            exit 1
        fi
        if [ "$PLATFORM" = "macos" ]; then
            if file "$bin" 2>/dev/null | grep -qi 'ELF'; then
                echo -e "${RED}ERROR: $bin is a Linux ELF binary — cannot run on macOS${NC}"
                echo "  Rebuild natively: cd '$PRP_DIR/src' && ./build_all"
                exit 1
            fi
        else
            if file "$bin" 2>/dev/null | grep -qi 'Mach-O'; then
                echo -e "${RED}ERROR: $bin is a macOS Mach-O binary — cannot run on Linux${NC}"
                echo "  Rebuild natively: cd '$PRP_DIR/src' && ./build_all"
                exit 1
            fi
        fi
        echo "  OK: $bin"
    done

    # Ensure scripts are executable
    chmod +x \
        "$PRP_DIR/RunPRPForCurDomain.sh" \
        "$PRP_DIR/PrintHuman_Policy.sh" \
        "$PRP_DIR/DrawDotPolicy.py" \
        "$PRP_DIR/prp/prp" \
        "$PRP_DIR/src/translate/translate.py" \
        "$PRP_DIR/src/preprocess/preprocess" \
        "$PRP_DIR/src/search/downward-release" \
        "$PRP_DIR/src/search/downward" \
        "$PRP_DIR/src/search/unitcost" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Remove PRP-generated scratch files between runs
# ---------------------------------------------------------------------------
cleanup_prp_files() {
    cd "$PRP_DIR"
    rm -f output output.sas policy.out policy.fsap elapsed.time \
          sas_plan plan_numbers_and_cost human_policy.out 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Step 4 — Generate PDDL files via cps2FondandVerify + copy to PRP
# ---------------------------------------------------------------------------
generate_and_copy_pddl() {
    local domains_to_run=("$@")

    # Ensure cps2FondandVerify dependencies are installed
    if [ -f "$CPS2FOND_DIR/requirements.txt" ]; then
        pip install -r "$CPS2FOND_DIR/requirements.txt" -q 2>/dev/null || true
    fi

    echo -e "${CYAN}=== [4/7] Generating PDDL files via cps2FondandVerify ===${NC}"

    cd "$CPS2FOND_DIR"
    mkdir -p autogenerated

    for domain in "${domains_to_run[@]}"; do
        local cpn="${DOMAIN_CPN[$domain]:-1}"
        echo "  python main.py -domainname $domain -cpn $cpn -deletehistory False -debug True"
        if python main.py -domainname "$domain" -cpn "$cpn" -deletehistory False -debug True >/tmp/cps2fond_${domain}.log 2>&1; then
            echo -e "       ${GREEN}OK${NC}"

            # --- Collect statistics for summary table ---
            STATS_ORDER+=("$domain")
            export STATS_I_${domain}="$cpn"

            # V: count predicates in the generated PDDL domain file
            local _pddl="$CPS2FOND_DIR/autogenerated/fond_${domain}_d.pddl"
            local _v=$(awk '/^[[:space:]]*\(:predicates/,/^[[:space:]]*\)/ {
                if (/^[[:space:]]*\([a-zA-Z]/ && !/^[[:space:]]*\(:predicates/) cnt++
            } END { print cnt+0 }' "$_pddl" 2>/dev/null)
            export STATS_V_${domain}="${_v:-0}"

            # T_g: generation time from log (seconds → ms)
            local _tg_s=$(sed -n 's/.*it cost: *\([0-9.]*\) *(s) to generate FOND abstraction.*/\1/p' \
                "/tmp/cps2fond_${domain}.log" 2>/dev/null)
            if [ -n "$_tg_s" ]; then
                export STATS_TG_${domain}=$(awk "BEGIN {printf \"%.2f\", $_tg_s * 1000}")
            else
                export STATS_TG_${domain}="--"
            fi

            # T_v: verification time from log (seconds → ms)
            local _tv_s=$(sed -n 's/.*it cost: *\([0-9.]*\) *(s) to verification.*/\1/p' \
                "/tmp/cps2fond_${domain}.log" 2>/dev/null)
            if [ -n "$_tv_s" ]; then
                export STATS_TV_${domain}=$(awk "BEGIN {printf \"%.2f\", $_tv_s * 1000}")
            else
                export STATS_TV_${domain}="--"
            fi
        else
            echo -e "       ${RED}FAIL — see /tmp/cps2fond_${domain}.log${NC}"
            echo "       ---- tail of /tmp/cps2fond_${domain}.log ----"
            tail -n 25 "/tmp/cps2fond_${domain}.log" | sed 's/^/         /'
            cd "$SAVG_ROOT"
            return 1
        fi
    done

    echo ""
    echo -e "${CYAN}=== [5/7] Patching domain PDDL files with synthetic goal action ===${NC}"
    python "$CPS2FOND_DIR/patch_fond_goal.py" "$CPS2FOND_DIR/autogenerated" || {
        echo -e "${RED}FAIL — patch_fond_goal.py failed${NC}"
        cd "$SAVG_ROOT"
        return 1
    }
    echo -e "       ${GREEN}OK — patched${NC}"

    echo ""
    echo -e "${CYAN}=== [6/7] Copying PDDL files to PRP autogenerated ===${NC}"

    local src_dir="$CPS2FOND_DIR/autogenerated"
    local dst_dir="$PRP_DIR/autogenerated"
    mkdir -p "$dst_dir"

    local copied=0
    for f in "$src_dir"/fond_*_d.pddl "$src_dir"/fond_*_p.pddl; do
        if [ -f "$f" ]; then
            cp "$f" "$dst_dir/"
            echo "  Copied: $(basename "$f")"
            copied=$((copied + 1))
        fi
    done
    echo "  Total copied: $copied files"

    cd "$SAVG_ROOT"
}

# ---------------------------------------------------------------------------
# Step 6 — run the full PRP pipeline for one domain
# ---------------------------------------------------------------------------
run_domain() {
    local domain="$1"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "  Domain: $domain"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Check for autogenerated PDDL files (skip if not produced yet)
    if [ ! -f "autogenerated/fond_${domain}_d.pddl" ] || \
       [ ! -f "autogenerated/fond_${domain}_p.pddl" ]; then
        echo -e "${YELLOW}SKIP: no autogenerated PDDL files for '$domain'${NC}"
        echo "  (looked for autogenerated/fond_${domain}_d.pddl)"
        SKIP=$((SKIP + 1))
        return 0
    fi

    cleanup_prp_files

    # --- 1. PRP solver + translate_policy.py ---
    echo "  [1/3] RunPRPForCurDomain.sh  → solving FOND problem ..."
    if ./RunPRPForCurDomain.sh "$domain" >/tmp/prp_${domain}.log 2>&1; then
        echo -e "       ${GREEN}OK — solver completed${NC}"
    else
        echo -e "       ${RED}FAIL — solver error (see /tmp/prp_${domain}.log)${NC}"
        echo "       ---- tail of /tmp/prp_${domain}.log ----"
        tail -n 25 /tmp/prp_${domain}.log | sed 's/^/         /'
        FAIL=$((FAIL + 1))
        FAILED_DOMAINS+=("$domain")
        return 1
    fi

    # --- 2. PrintHuman_Policy.sh ---
    echo "  [2/3] PrintHuman_Policy.sh   → human-readable policy ..."
    if ./PrintHuman_Policy.sh "$domain" 2>/dev/null && \
       [ -f "solutionsByPRP/fond_${domain}_human_policy.out" ]; then
        echo -e "       ${GREEN}OK — policy written${NC}"

        # π: count "If holds:" lines in the human policy file
        local _policy_file="solutionsByPRP/fond_${domain}_human_policy.out"
        local _pi=$(grep -c 'If holds:' "$_policy_file" 2>/dev/null || echo 0)
        export STATS_PI_${domain}="${_pi}"
    else
        echo -e "       ${YELLOW}WARN — human_policy.out not produced${NC}"
    fi

    # --- 3. DrawDotPolicy.py ---
    echo "  [3/3] DrawDotPolicy.py       → policy graph (.dot/.png) ..."
    if python ./DrawDotPolicy.py -domainname "$domain" 2>/dev/null && \
       [ -f "solutionsByPRP/fond_${domain}.png" ]; then
        echo -e "       ${GREEN}OK — graph rendered${NC}"
    else
        echo -e "       ${YELLOW}WARN — graph not produced${NC}"
    fi

    PASS=$((PASS + 1))
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    # --- Parse optional -domain argument ---
    local selected_domain=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -domain)
                if [[ -z "${2:-}" ]]; then
                    echo -e "${RED}ERROR: -domain requires a domain name argument${NC}"
                    echo "  Usage: $0 [-domain <domain_name>]"
                    echo "  Available domains: ${DOMAINS[*]}"
                    exit 1
                fi
                selected_domain="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}ERROR: unknown option: $1${NC}"
                echo "  Usage: $0 [-domain <domain_name>]"
                exit 1
                ;;
        esac
    done

    # Build the list of domains to run
    local domains_to_run=()
    if [[ -n "$selected_domain" ]]; then
        # Validate the domain name
        local found=0
        for d in "${DOMAINS[@]}"; do
            if [[ "$d" == "$selected_domain" ]]; then
                found=1
                break
            fi
        done
        if [[ $found -eq 0 ]]; then
            echo -e "${RED}ERROR: unknown domain '$selected_domain'${NC}"
            echo "  Available domains: ${DOMAINS[*]}"
            exit 1
        fi
        domains_to_run=("$selected_domain")
    else
        domains_to_run=("${DOMAINS[@]}")
    fi

    echo "############################################################"
    echo "#  SAVG · PRP Full Test Suite"
    echo "#  Runs every test case from"
    echo "#  PRP_planner-for-relevant-policies/usage_README.md"
    echo "#  Platform: $PLATFORM"
    echo "############################################################"

    setup_venv
    check_dependencies
    verify_binaries

    generate_and_copy_pddl "${domains_to_run[@]}" || {
        echo -e "${RED}FATAL: PDDL generation failed — aborting${NC}"
        exit 1
    }

    echo ""
    echo -e "${CYAN}=== [7/7] Running ${#domains_to_run[@]} test domain(s) ===${NC}"
    cd "$PRP_DIR"
    mkdir -p solutionsByPRP

    for domain in "${domains_to_run[@]}"; do
        run_domain "$domain"
    done

    cleanup_prp_files

    # --- Summary ---
    echo ""
    echo "############################################################"
    echo "#  Summary"
    echo "############################################################"
    echo "  Total : ${#domains_to_run[@]}"
    echo -e "  ${GREEN}Passed: $PASS${NC}"
    echo -e "  ${YELLOW}Skipped: $SKIP${NC}  (no autogenerated PDDL)"
    echo -e "  ${RED}Failed: $FAIL${NC}"
    if [ "${#FAILED_DOMAINS[@]}" -gt 0 ]; then
        echo "  Failed domains: ${FAILED_DOMAINS[*]}"
    fi
    echo ""

    # --- Statistics Table ---
    if [ "${#STATS_ORDER[@]}" -gt 0 ]; then
        echo "############################################################"
        echo "#  Statistics"
        echo "############################################################"
        printf "| %-13s | %2s | %2s | %8s | %8s | %2s | %-6s |\n" \
            "Domain" "I" "V" "T_g(ms)" "T_v(ms)" "π" "TC"
        printf "|%-15s|%-4s|%-4s|%-10s|%-10s|%-4s|%-8s|\n" \
            "---------------" "----" "----" "----------" "----------" "----" "--------"
        local _disp _i _v _tg _tv _pi _tc
        for domain in "${STATS_ORDER[@]}"; do
            _disp="${DOMAIN_DISPLAY[$domain]:-$domain}"
            # Use eval for safe indirect expansion under set -u
            _i=$(eval "echo \${STATS_I_${domain}:---}" 2>/dev/null)
            _v=$(eval "echo \${STATS_V_${domain}:---}" 2>/dev/null)
            _tg=$(eval "echo \${STATS_TG_${domain}:---}" 2>/dev/null)
            _tv=$(eval "echo \${STATS_TV_${domain}:---}" 2>/dev/null)
            _pi=$(eval "echo \${STATS_PI_${domain}:---}" 2>/dev/null)
            case "$domain" in
                TreeChop|NestedVar|TrashCollection|Snow|DeliveryFuel) _tc="Cond." ;;
                *)                                  _tc="Fair"  ;;
            esac
            printf "| %-13s | %2s | %2s | %8s | %8s | %2s | %-6s |\n" \
                "$_disp" "$_i" "$_v" "$_tg" "$_tv" "$_pi" "$_tc"
        done
        echo ""
    fi

    [ $FAIL -eq 0 ] && exit 0 || exit 1
}

main "$@"
