#!/bin/bash

# Atopile Linting and Validation Script
# Runs various checks and validations on atopile projects

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
EXIT_CODE=0
VERBOSE=false
FIX_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--fix)
            FIX_MODE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose    Show detailed output"
            echo "  -f, --fix        Attempt to fix issues automatically"
            echo "  -h, --help       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}🔍 Running atopile project linting and validation...${NC}"
echo ""

# Function to log messages
log() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "$1"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run a check and track results
run_check() {
    local check_name="$1"
    local command="$2"
    local description="$3"

    echo -e "${CYAN}🔧 $check_name${NC}"
    log "   Running: $command"

    if eval "$command"; then
        echo -e "${GREEN}   ✅ $description${NC}"
    else
        echo -e "${RED}   ❌ $description${NC}"
        EXIT_CODE=1
    fi
    echo ""
}

# Check 1: Verify ato.yaml exists and is valid
check_config() {
    if [[ ! -f "ato.yaml" ]]; then
        echo -e "${RED}   ❌ ato.yaml not found${NC}"
        return 1
    fi

    # Basic check - just see if file is readable and non-empty
    if [[ ! -s "ato.yaml" ]]; then
        echo -e "${RED}   ❌ ato.yaml is empty${NC}"
        return 1
    fi

    # Check if file has required fields
    if ! grep -q "requires-atopile:" ato.yaml; then
        echo -e "${YELLOW}   ⚠️  ato.yaml missing 'requires-atopile' field${NC}"
    fi
}

# Check 2: Validate .ato files syntax
check_syntax() {
    local ato_files=$(find . -name "*.ato" -not -path "./build/*" -not -path "./.ato/*")

    if [[ -z "$ato_files" ]]; then
        echo -e "${YELLOW}   ⚠️  No .ato files found${NC}"
        return 0
    fi

    local syntax_errors=0
    while IFS= read -r file; do
        log "   Checking syntax: $file"
        if ! ato validate "$file" >/dev/null 2>&1; then
            echo -e "${RED}   Syntax error in: $file${NC}"
            if [[ "$VERBOSE" == true ]]; then
                ato validate "$file" 2>&1 | head -3
            fi
            syntax_errors=$((syntax_errors + 1))
        fi
    done <<< "$ato_files"

    if [[ $syntax_errors -eq 0 ]]; then
        return 0
    else
        echo -e "${RED}   Found $syntax_errors syntax error(s)${NC}"
        return 1
    fi
}

# Check 3: Run atopile's built-in checks
check_atopile_validation() {
    local ato_files=$(find . -name "*.ato" -not -path "./build/*" -not -path "./.ato/*")
    local validation_errors=0

    while IFS= read -r file; do
        log "   Validating: $file"
        if ! ato validate "$file" >/dev/null 2>&1; then
            echo -e "${RED}   Validation failed for: $file${NC}"
            validation_errors=$((validation_errors + 1))
        fi
    done <<< "$ato_files"

    return $validation_errors
}

# Check 4: Check for common issues
check_common_issues() {
    local issues=0

    # Check for trailing whitespace in .ato files
    log "   Checking for trailing whitespace..."
    if find . -name "*.ato" -not -path "./build/*" -exec grep -l '[[:space:]]$' {} \; | head -1 | grep -q .; then
        echo -e "${YELLOW}   ⚠️  Found trailing whitespace in .ato files${NC}"
        if [[ "$FIX_MODE" == true ]]; then
            echo -e "${BLUE}   🔧 Fixing trailing whitespace...${NC}"
            find . -name "*.ato" -not -path "./build/*" -exec sed -i '' 's/[[:space:]]*$//' {} \;
            echo -e "${GREEN}   ✅ Fixed trailing whitespace${NC}"
        else
            issues=$((issues + 1))
        fi
    fi

    # Check for mixed line endings
    log "   Checking for mixed line endings..."
    if find . -name "*.ato" -not -path "./build/*" -exec file {} \; | grep -q "CRLF"; then
        echo -e "${YELLOW}   ⚠️  Found Windows line endings (CRLF) in .ato files${NC}"
        if [[ "$FIX_MODE" == true ]]; then
            echo -e "${BLUE}   🔧 Converting to Unix line endings...${NC}"
            find . -name "*.ato" -not -path "./build/*" -exec dos2unix {} \; 2>/dev/null || true
            echo -e "${GREEN}   ✅ Converted line endings${NC}"
        else
            issues=$((issues + 1))
        fi
    fi

    # Check for very long lines
    log "   Checking for long lines..."
    local long_lines=$(find . -name "*.ato" -not -path "./build/*" -exec awk 'length > 120 {print FILENAME ":" NR ": " $0}' {} \;)
    if [[ -n "$long_lines" ]]; then
        echo -e "${YELLOW}   ⚠️  Found lines longer than 120 characters:${NC}"
        if [[ "$VERBOSE" == true ]]; then
            echo "$long_lines" | head -5
        fi
        issues=$((issues + 1))
    fi

    return $issues
}

# Check 5: Verify dependencies
check_dependencies() {
    if [[ -f "ato.yaml" ]] && grep -q "dependencies:" ato.yaml; then
        log "   Checking if dependencies are installed..."
        # This would need to be implemented based on atopile's dependency system
        # For now, just check if .ato directory exists (where deps are typically stored)
        if [[ -d ".ato" ]]; then
            return 0
        else
            echo -e "${YELLOW}   ⚠️  Dependencies directory not found. Run 'ato install'${NC}"
            return 1
        fi
    fi
    return 0
}

# Check 6: Build test
check_build() {
    log "   Running test build..."
    ato build --dry-run 2>/dev/null || ato build
}

# Run all checks
echo -e "${BLUE}📋 Running validation checks...${NC}"
echo ""

run_check "Configuration Check" "check_config" "ato.yaml is valid"
run_check "Syntax Check" "check_syntax" "All .ato files have valid syntax"
run_check "Atopile Validation" "check_atopile_validation" "Atopile built-in checks pass"
run_check "Common Issues" "check_common_issues" "No common code issues found"
run_check "Dependencies" "check_dependencies" "Dependencies are properly installed"
run_check "Build Check" "check_build" "Project builds successfully"

# Summary
echo -e "${BLUE}📊 Linting Summary${NC}"
echo "=================================="

if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}🎉 All checks passed! Your atopile project looks good.${NC}"
else
    echo -e "${RED}❌ Some checks failed. Please review the issues above.${NC}"
    if [[ "$FIX_MODE" != true ]]; then
        echo -e "${YELLOW}💡 Tip: Run with --fix flag to automatically fix some issues.${NC}"
    fi
fi

echo ""
echo -e "${BLUE}🔧 Available commands:${NC}"
echo "  ato build          - Build the project"
echo "  ato validate       - Run atopile validation"
echo "  ato install        - Install dependencies"
echo "  ./scripts/watch.sh - Start file watcher"

exit $EXIT_CODE
