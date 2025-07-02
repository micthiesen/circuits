# Atopile Project Makefile
# Convenient commands for development workflow

.PHONY: help build watch lint clean install check format deps setup test

# Default target
help: ## Show this help message
	@echo "Atopile Project Commands:"
	@echo "========================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Development commands
build: ## Build the atopile project
	@echo "🔨 Building project..."
	ato build

watch: ## Start file watcher for automatic builds
	@echo "👀 Starting file watcher..."
	./scripts/watch.sh

lint: ## Run linting and validation checks
	@echo "🔍 Running linter..."
	./scripts/lint.sh

lint-fix: ## Run linting with automatic fixes
	@echo "🔧 Running linter with fixes..."
	./scripts/lint.sh --fix

lint-verbose: ## Run linting with verbose output
	@echo "🔍 Running verbose linter..."
	./scripts/lint.sh --verbose

# Project management
check: ## Run atopile validation checks
	@echo "✅ Running atopile validation..."
	ato validate main.ato

install: ## Install project dependencies
	@echo "📦 Installing dependencies..."
	ato sync

clean: ## Clean build artifacts
	@echo "🧹 Cleaning build directory..."
	rm -rf build/
	rm -rf layouts/*/default.kicad_pcb.bak*

format: ## Format atopile files
	@echo "💅 Formatting code..."
	find . -name "*.ato" -not -path "./build/*" -not -path "./.ato/*" -exec ato fmt {} \; 2>/dev/null || echo "⚠️  Format command not available in this atopile version"

# KiCAD integration
kicad: ## Build and open KiCAD
	@echo "🖥️  Building and opening KiCAD..."
	ato build --open

pcb: ## Open PCB layout in KiCAD
	@echo "🖥️  Opening PCB layout..."
	@if [ -f "layouts/default/default.kicad_pcb" ]; then \
		open "layouts/default/default.kicad_pcb"; \
	else \
		echo "❌ PCB file not found. Run 'make build' first."; \
	fi

# Setup and dependencies
setup: ## Initial project setup
	@echo "🚀 Setting up development environment..."
	@echo "Checking dependencies..."
	@command -v ato >/dev/null 2>&1 || { echo "❌ atopile not installed. Install with: brew install atopile/tap/atopile"; exit 1; }
	@command -v fswatch >/dev/null 2>&1 || { echo "📦 Installing fswatch..."; brew install fswatch; }
	@echo "Making scripts executable..."
	@chmod +x scripts/*.sh
	@echo "✅ Setup complete!"

deps: setup ## Alias for setup

# Testing and validation
test: lint check build ## Run all tests and validations
	@echo "🧪 All tests completed!"

# Development workflow
dev: ## Start development workflow (build + watch)
	@echo "🚀 Starting development workflow..."
	@make build
	@make watch

# Info commands
info: ## Show project information
	@echo "📋 Project Information:"
	@echo "======================"
	@echo "Project: $(shell basename $(PWD))"
	@echo "Atopile version: $(shell ato --version 2>/dev/null || echo 'Not installed')"
	@echo "Source files: $(shell find . -name '*.ato' -not -path './build/*' -not -path './.ato/*' | wc -l | tr -d ' ')"
	@echo "Config file: $(shell [ -f ato.yaml ] && echo '✅ Found' || echo '❌ Missing')"
	@echo "Build dir: $(shell [ -d build ] && echo '✅ Present' || echo '❌ Not found')"
	@echo "Layout dir: $(shell [ -d layouts ] && echo '✅ Present' || echo '❌ Not found')"

status: info ## Alias for info

# Git integration
commit-check: test ## Run checks before committing
	@echo "🔍 Pre-commit validation..."
	@git status --porcelain
	@echo "✅ Ready to commit!"

# Documentation
docs: ## Generate documentation (placeholder)
	@echo "📚 Documentation generation not yet implemented"
	@echo "For now, check README.md and inline comments"

# Quick shortcuts
b: build    ## Quick build
w: watch    ## Quick watch
l: lint     ## Quick lint
c: check    ## Quick validate
i: install  ## Quick sync

# Advanced commands
debug: ## Build with debug information
	@echo "🐛 Building with debug info..."
	ato build --verbose

profile: ## Profile build performance
	@echo "⏱️  Profiling build..."
	time ato build

validate-config: ## Validate ato.yaml configuration
	@echo "🔧 Validating configuration..."
	@python3 -c "import yaml; print('✅ ato.yaml is valid YAML'); yaml.safe_load(open('ato.yaml'))" 2>/dev/null || echo "❌ ato.yaml validation failed"

# Production commands
release-check: ## Check if ready for release
	@echo "🚀 Release readiness check..."
	@make clean
	@make test
	@git status --porcelain | grep -q . && echo "❌ Uncommitted changes found" || echo "✅ Git status clean"
	@echo "✅ Release check complete!"
