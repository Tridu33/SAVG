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
VENV_DIR="$SAVG_ROOT/.venv"

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
# Step 4 — run the full pipeline for one domain
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
    echo "############################################################"
    echo "#  SAVG · PRP Full Test Suite"
    echo "#  Runs every test case from"
    echo "#  PRP_planner-for-relevant-policies/usage_README.md"
    echo "#  Platform: $PLATFORM"
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

    [ $FAIL -eq 0 ] && exit 0 || exit 1
}

main "$@"