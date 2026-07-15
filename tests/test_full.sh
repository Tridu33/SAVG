#!/bin/bash
#
# test-full.sh — Run every PRP test case listed in
#   PRP_planner-for-relevant-policies/usage_README.md
#
# For each domain the script executes the three-step pipeline documented in
# the README:
#   1. ./RunPRPForCurDomain.sh <domain>   (PRP solver + policy translation)
#   2. ./PrintHuman_Policy.sh <domain>    (re-translate policy to human format)
#   3. python ./DrawDotPolicy.py -domainname <domain>  (render policy graph)
#
# With the --generate flag, also runs cps2FondandVerify/main.py to generate
# the FOND PDDL files from the classical planning instances, and collects
# generation timing (Tg), verification timing (Tv), solution size (|π|),
# number of instances (I), and refinement mapping size (n).
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
CPS_DIR="$SAVG_ROOT/cps2FondandVerify"
VENV_DIR="$SAVG_ROOT/.venv"

# ---------------------------------------------------------------------------
# Generate PDDL files?  (set by --generate)
# ---------------------------------------------------------------------------
GENERATE_FLAG=false

# ---------------------------------------------------------------------------
# 10 original domains from usage_README.md (lines 5-43 and 78-80)
# + 6 new domains generated via cps2FondandVerify/main.py
#   (TreeChop, NestedVar, Snow, DeliveryFuel, TrashCollection,
#    35bottle4Lwater)
# ---------------------------------------------------------------------------
DOMAINS=(
    llvisitall
    reversell
    blocks_clear
    stripedtower
    RGBBlocks
    treetraversal
    3colorblocks
    striped
    3delivery
    choppingtree2
    TreeChop
    NestedVar
    Snow
    DeliveryFuel
    TrashCollection
    35bottle4Lwater
)

# ---------------------------------------------------------------------------
# Domain parameters for generation and table display
# ---------------------------------------------------------------------------
# Number of classical planning instances (cpn) per domain
declare -A CPN
CPN["blocks_clear"]=1
CPN["llvisitall"]=3
CPN["reversell"]=1
CPN["stripedtower"]=4
CPN["RGBBlocks"]=4
CPN["treetraversal"]=4
CPN["3colorblocks"]=4
CPN["striped"]=4
CPN["3delivery"]=4
CPN["choppingtree2"]=2
CPN["TreeChop"]=3
CPN["NestedVar"]=3
CPN["Snow"]=3
CPN["DeliveryFuel"]=3
CPN["TrashCollection"]=3
CPN["35bottle4Lwater"]=1

# Planner type per domain
declare -A PLANNER
PLANNER["blocks_clear"]="PRP"
PLANNER["llvisitall"]="PRP"
PLANNER["reversell"]="PRP"
PLANNER["stripedtower"]="PRP"
PLANNER["RGBBlocks"]="PRP"
PLANNER["treetraversal"]="PRP"
PLANNER["3colorblocks"]="PRP"
PLANNER["striped"]="PRP"
PLANNER["3delivery"]="PRP"
PLANNER["choppingtree2"]="PRP"
PLANNER["TreeChop"]="FONDASP"
PLANNER["NestedVar"]="FONDASP"
PLANNER["Snow"]="FONDASP"
PLANNER["DeliveryFuel"]="FONDASP"
PLANNER["TrashCollection"]="FONDASP"
PLANNER["35bottle4Lwater"]="FONDASP"

# Domain display names for the table (folder → table name)
declare -A DISPLAY_NAME
DISPLAY_NAME["blocks_clear"]="ClearA"
DISPLAY_NAME["llvisitall"]="Visitall"
DISPLAY_NAME["reversell"]="ReverseLL"
DISPLAY_NAME["stripedtower"]="Striped"
DISPLAY_NAME["RGBBlocks"]="RGBBlocks"
DISPLAY_NAME["treetraversal"]="TreeTraverse"
DISPLAY_NAME["3colorblocks"]="3ColorBlocks"
DISPLAY_NAME["striped"]="Striped"
DISPLAY_NAME["3delivery"]="3Delivery"
DISPLAY_NAME["choppingtree2"]="ChopTree2"
DISPLAY_NAME["TreeChop"]="TreeChop"
DISPLAY_NAME["NestedVar"]="NestedVar"
DISPLAY_NAME["Snow"]="Snow"
DISPLAY_NAME["DeliveryFuel"]="DeliveryFuel"
DISPLAY_NAME["TrashCollection"]="TrashCollection"
DISPLAY_NAME["35bottle4Lwater"]="35bottle4Lwater"

# Trajectory constraint type
declare -A TC_TYPE
TC_TYPE["blocks_clear"]="Fair"
TC_TYPE["llvisitall"]="Fair"
TC_TYPE["reversell"]="Fair"
TC_TYPE["stripedtower"]="Fair"
TC_TYPE["RGBBlocks"]="Fair"
TC_TYPE["treetraversal"]="Fair"
TC_TYPE["3colorblocks"]="Fair"
TC_TYPE["striped"]="Fair"
TC_TYPE["3delivery"]="Fair"
TC_TYPE["choppingtree2"]="Fair"
TC_TYPE["TreeChop"]="Cond."
TC_TYPE["NestedVar"]="Cond."
TC_TYPE["Snow"]="Cond."
TC_TYPE["DeliveryFuel"]="Cond."
TC_TYPE["TrashCollection"]="Cond."
TC_TYPE["35bottle4Lwater"]="Cond."

# Per-domain timing (seconds) — associative arrays to avoid cross-domain leakage
declare -A TGS   # generation time Tg
declare -A TVS   # verification time Tv

# ---------------------------------------------------------------------------
# Results array — each entry: "I|n|Tg|Tv|pi|TC|display_name"
# ---------------------------------------------------------------------------
declare -a RESULTS

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
    echo -e "${CYAN}=== [1/4] Setting up Python virtual environment (uv) ===${NC}"
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
    echo -e "${CYAN}=== [2/4] Checking system dependencies ===${NC}"

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
    echo -e "${CYAN}=== [3/4] Verifying PRP solver binaries ===${NC}"

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
        "$PRP_DIR/src/search/downward" 2>/dev/null || true
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
# Count I (number of problem instances) for a domain
# ---------------------------------------------------------------------------
count_I() {
    local domain="$1"
    # Use CPN map first (matches the experiment configuration)
    if [ -n "${CPN[$domain]:-}" ]; then
        echo "${CPN[$domain]}"
        return
    fi
    # Fall back to counting files
    local count
    count=$(ls "$CPS_DIR/domain/$domain/low_${domain}_p"*.pddl 2>/dev/null | wc -l)
    echo "$count"
}

# ---------------------------------------------------------------------------
# Count n (number of :derived predicates = abstract atoms) for a domain
# ---------------------------------------------------------------------------
count_n() {
    local domain="$1"
    local count
    # Count (:derived blocks in the low-level domain PDDL (non-comment lines only)
    count=$(grep -cP '^\s*\(:derived' "$CPS_DIR/domain/$domain/low_${domain}_d.pddl" 2>/dev/null)
    if [ -z "$count" ] || [ "$count" -eq 0 ]; then
        # Fallback: count from fond domain predicates (minus vStart, vGoal)
        local fond_file="$PRP_DIR/autogenerated/fond_${domain}_d.pddl"
        if [ -f "$fond_file" ]; then
            count=$(sed -n '/:predicates/,/)/p' "$fond_file" 2>/dev/null | grep -c '^\s*(')
            count=$((count - 2))  # remove vStart, vGoal
            [ "$count" -lt 0 ] && count=0
        fi
    fi
    echo "${count:-0}"
}

# ---------------------------------------------------------------------------
# Count |π| (number of unique actions in the PRP policy)
# ---------------------------------------------------------------------------
count_pi() {
    local domain="$1"
    local policy_out="$PRP_DIR/solutionsByPRP/fond_${domain}_human_policy.out"
    if [ ! -f "$policy_out" ]; then
        echo "0"
        return
    fi
    # Count unique action names in "Execute: <action>" lines
    grep "Execute:" "$policy_out" 2>/dev/null | awk '{print $2}' | sort -u | wc -l
}

# ---------------------------------------------------------------------------
# Run generation step (cps2FondandVerify/main.py) with timing
# ---------------------------------------------------------------------------
generate_domain() {
    local domain="$1"
    local cpn="${CPN[$domain]:-1}"
    local planner="${PLANNER[$domain]:-PRP}"

    echo "  [gen] Generating FOND abstraction (cpn=$cpn, planner=$planner) ..."
    cd "$CPS_DIR" || return 1

    # Clean previous autogenerated files for a fresh measurement
    rm -f "autogenerated/fond_${domain}_d.pddl" "autogenerated/fond_${domain}_p.pddl" 2>/dev/null

    local gen_start gen_end tg
    gen_start=$(date +%s.%N)
    $VENV_DIR/bin/python main.py \
        -domainname "$domain" \
        -cpn "$cpn" \
        -planner "$planner" \
        -deletehistory True \
        -debug False \
        > "/tmp/gen_${domain}.log" 2>&1
    local ret=$?
    gen_end=$(date +%s.%N)

    tg=$(echo "$gen_end - $gen_start" | bc 2>/dev/null || echo "0")
    # Format to 2 decimal places
    TGS[$domain]=$(printf "%.2f" "$tg" 2>/dev/null || echo "$tg")

    if [ $ret -ne 0 ]; then
        echo -e "       ${RED}FAIL — generation error (see /tmp/gen_${domain}.log)${NC}"
        tail -n 20 "/tmp/gen_${domain}.log" | sed 's/^/         /'
        return 1
    fi

    # Also extract generation time from main.py stdout (more precise)
    local gen_line
    gen_line=$(grep "it cost:" "/tmp/gen_${domain}.log" | grep "generate" | head -1)
    if [ -n "$gen_line" ]; then
        tg_raw=$(echo "$gen_line" | grep -oP '[\d.]+' | head -1)
        TGS[$domain]=$(printf "%.2f" "$tg_raw" 2>/dev/null || echo "$tg_raw")
    fi
    echo -e "       ${GREEN}OK — Tg=${TGS[$domain]}s${NC}"

    # Run patch_fond_goal.py to add synthetic goal actions for Cond. domains
    if [ -f "patch_fond_goal.py" ]; then
        $VENV_DIR/bin/python patch_fond_goal.py "autogenerated/" \
            >> "/tmp/gen_${domain}.log" 2>&1
    fi

    # Copy generated files to PRP directory
    mkdir -p "$PRP_DIR/autogenerated"
    if [ -f "autogenerated/fond_${domain}_d.pddl" ]; then
        cp "autogenerated/fond_${domain}_d.pddl" "$PRP_DIR/autogenerated/"
    fi
    if [ -f "autogenerated/fond_${domain}_p.pddl" ]; then
        cp "autogenerated/fond_${domain}_p.pddl" "$PRP_DIR/autogenerated/"
    fi

    return 0
}

# ---------------------------------------------------------------------------
# Run the full pipeline for one domain
# ---------------------------------------------------------------------------
run_domain() {
    local domain="$1"
    local display="${DISPLAY_NAME[$domain]:-$domain}"
    local tc="${TC_TYPE[$domain]:--}"
    local I_val n_val pi_val tg_val tv_val
    local domain_start domain_end domain_total
    domain_start=$(date +%s.%N)

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "  Domain: $domain  (Table: $display)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # --- 0. Generation step (if --generate) ---
    if [ "$GENERATE_FLAG" = true ]; then
        if ! generate_domain "$domain"; then
            # Generation failed — mark as failed but still try PRP if PDDL exists
            if [ ! -f "$PRP_DIR/autogenerated/fond_${domain}_d.pddl" ]; then
                FAIL=$((FAIL + 1))
                FAILED_DOMAINS+=("$domain")
                # Still collect metadata
                I_val=$(count_I "$domain")
                n_val=$(count_n "$domain")
                RESULTS+=("$I_val|$n_val|FAIL|—|—|$tc|$display")
                return 1
            fi
        fi
    fi

    # Check for autogenerated PDDL files (skip if not produced yet)
    if [ ! -f "$PRP_DIR/autogenerated/fond_${domain}_d.pddl" ] || \
       [ ! -f "$PRP_DIR/autogenerated/fond_${domain}_p.pddl" ]; then
        echo -e "${YELLOW}SKIP: no autogenerated PDDL files for '$domain'${NC}"
        echo "  (looked for $PRP_DIR/autogenerated/fond_${domain}_d.pddl)"
        # Still collect metadata
        I_val=$(count_I "$domain")
        n_val=$(count_n "$domain")
        RESULTS+=("$I_val|$n_val|—|—|—|$tc|$display")
        SKIP=$((SKIP + 1))
        return 0
    fi

    cleanup_prp_files

    # --- 1. PRP solver + translate_policy.py (with timing) ---
    echo "  [1/3] RunPRPForCurDomain.sh  → solving FOND problem ..."
    local tv_raw
    /usr/bin/time -f "%e" -o "/tmp/prp_${domain}_time.txt" \
        ./RunPRPForCurDomain.sh "$domain" >"/tmp/prp_${domain}.log" 2>&1
    local ret=$?
    tv_raw=$(cat "/tmp/prp_${domain}_time.txt" 2>/dev/null || echo "0")
    TVS[$domain]=$(printf "%.2f" "$tv_raw" 2>/dev/null || echo "$tv_raw")
    tv_val="${TVS[$domain]}"

    if [ $ret -eq 0 ]; then
        echo -e "       ${GREEN}OK — solver completed (Tv=${tv_val}s)${NC}"
    else
        echo -e "       ${RED}FAIL — solver error (see /tmp/prp_${domain}.log)${NC}"
        echo "       ---- tail of /tmp/prp_${domain}.log ----"
        tail -n 25 "/tmp/prp_${domain}.log" | sed 's/^/         /'
        tv_val="FAIL"
        # Continue to collect whatever data we can
    fi

    # --- 2. PrintHuman_Policy.sh ---
    echo "  [2/3] PrintHuman_Policy.sh   → human-readable policy ..."
    if ./PrintHuman_Policy.sh "$domain" 2>/dev/null && \
       [ -f "$PRP_DIR/solutionsByPRP/fond_${domain}_human_policy.out" ]; then
        echo -e "       ${GREEN}OK — policy written${NC}"
    else
        echo -e "       ${YELLOW}WARN — human_policy.out not produced${NC}"
    fi

    # --- 3. DrawDotPolicy.py ---
    echo "  [3/3] DrawDotPolicy.py       → policy graph (.dot/.png) ..."
    if python ./DrawDotPolicy.py -domainname "$domain" 2>/dev/null && \
       [ -f "$PRP_DIR/solutionsByPRP/fond_${domain}.png" ]; then
        echo -e "       ${GREEN}OK — graph rendered${NC}"
    else
        echo -e "       ${YELLOW}WARN — graph not produced${NC}"
    fi

    # --- Domain total time ---
    domain_end=$(date +%s.%N)
    domain_total=$(echo "$domain_end - $domain_start" | bc 2>/dev/null || echo "0")
    printf "       ${CYAN}▶ Domain total: %.2fs${NC}\n" "$domain_total"

    # --- Collect data ---
    I_val=$(count_I "$domain")
    n_val=$(count_n "$domain")
    pi_val=$(count_pi "$domain")

    # For Tg: if generation was done, use the captured value from TGS array
    if [ "$GENERATE_FLAG" = true ] && [ -n "${TGS[$domain]:-}" ]; then
        tg_val="${TGS[$domain]}"
    else
        tg_val="—"
    fi

    RESULTS+=("$I_val|$n_val|${tg_val}|${tv_val}|${pi_val}|$tc|$display")

    if [ "$ret" -eq 0 ]; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
        FAILED_DOMAINS+=("$domain")
    fi
}

# ---------------------------------------------------------------------------
# Print the summary table
# ---------------------------------------------------------------------------
print_table() {
    echo ""
    echo "############################################################"
    echo "#  Table 1: Generation and verification results"
    echo "############################################################"
    printf "| %-14s | %-2s | %-2s | %-7s | %-7s | %-3s | %-6s |\n" "Domain" "I" "n" "Tg(s)" "Tv(s)" "|π|" "TC"
    printf "|%s|%s|%s|%s|%s|%s|%s|\n" \
        "----------------" "----" "----" "-------" "-------" "-----" "--------"

    for result in "${RESULTS[@]}"; do
        IFS='|' read -r i_val n_val tg_val tv_val pi_val tc_val name_val <<< "$result"
        printf "| %-14s | %-2s | %-2s | %-7s | %-7s | %-3s | %-6s |\n" \
            "$name_val" "$i_val" "$n_val" "$tg_val" "$tv_val" "$pi_val" "$tc_val"
    done

    echo ""
    echo "Columns:"
    echo "  I     — number of classical planning instances"
    echo "  n     — size of the refinement mapping m"
    echo "  Tg(s) — generation time in seconds (cps2FondandVerify/main.py)"
    echo "  Tv(s) — verification time in seconds (PRP solver)"
    echo "  |π|   — solution size (# of unique actions in policy)"
    echo "  TC    — trajectory constraint type (Fair / Cond.)"
    echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --generate)
                GENERATE_FLAG=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--generate]"
                echo "  --generate    Run the full pipeline including FOND generation"
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done

    echo "############################################################"
    echo "#  SAVG · PRP Full Test Suite"
    echo "#  Runs every test case from"
    echo "#  PRP_planner-for-relevant-policies/usage_README.md"
    echo "#  Platform: $PLATFORM"
    echo "#  Generate: $GENERATE_FLAG"
    echo "############################################################"

    setup_venv
    check_dependencies
    verify_binaries

    echo ""
    echo -e "${CYAN}=== [4/4] Running ${#DOMAINS[@]} test domains ===${NC}"
    cd "$PRP_DIR"
    mkdir -p solutionsByPRP

    for domain in "${DOMAINS[@]}"; do
        run_domain "$domain"
    done

    cleanup_prp_files

    # --- Summary ---
    echo ""
    echo "############################################################"
    echo "#  Summary"
    echo "############################################################"
    echo "  Total : ${#DOMAINS[@]}"
    echo -e "  ${GREEN}Passed: $PASS${NC}"
    echo -e "  ${YELLOW}Skipped: $SKIP${NC}  (no autogenerated PDDL)"
    echo -e "  ${RED}Failed: $FAIL${NC}"
    if [ "${#FAILED_DOMAINS[@]}" -gt 0 ]; then
        echo "  Failed domains: ${FAILED_DOMAINS[*]}"
    fi
    echo ""

    # Print results table
    print_table

    [ $FAIL -eq 0 ] && exit 0 || exit 1
}

main "$@"
