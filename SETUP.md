# Atopile Development Environment Setup

## 🎉 Setup Complete!

Your atopile DIY circuit design environment is fully configured and ready to use.

## 📋 What's Been Installed & Configured

### Core Tools
- ✅ **Atopile 0.10.5** - Circuit design compiler
- ✅ **fswatch** - File system watcher for auto-builds
- ✅ **Project structure** - Organized directory layout
- ✅ **Development scripts** - Automated tooling

### Development Environment
- ✅ **Zed editor configuration** (.zed/settings.json)
- ✅ **File watcher script** (scripts/watch.sh)
- ✅ **Linting & validation** (scripts/lint.sh)
- ✅ **Makefile** with convenient commands
- ✅ **Project documentation** (README.md)

### Project Files
```
circuits/
├── ato.yaml              # Project configuration
├── main.ato              # Your circuit definitions
├── Makefile              # Development commands
├── README.md             # Comprehensive documentation
├── SETUP.md              # This file
├── .zed/
│   └── settings.json     # Zed editor config
├── scripts/
│   ├── watch.sh          # File watcher (auto-build)
│   └── lint.sh           # Code quality checks
├── build/                # Generated build artifacts
└── layouts/              # KiCAD PCB files
```

## 🚀 Quick Start Commands

### Essential Commands
```bash
# Show all available commands
make help

# Build your circuit
make build

# Start development mode (auto-rebuild on changes)
make watch

# Run code quality checks
make lint

# Validate circuit syntax
make check

# Clean build artifacts
make clean
```

### Development Workflow
```bash
# 1. Start with a clean build
make build

# 2. Begin development (in a separate terminal)
make watch

# 3. Edit your .ato files in Zed
# 4. Watch automatic builds happen
# 5. Run quality checks
make lint

# 6. Open in KiCAD when ready
make kicad
```

## 📝 Next Steps

### 1. Learn Atopile Syntax
- Edit `main.ato` to create your first circuit
- Use the extensive documentation in `README.md`
- Check out [atopile.io](https://atopile.io) for tutorials

### 2. Add Components
```bash
# Search for parts by LCSC number
ato create part --search C1234 --accept-single

# Add package dependencies
ato add package-name
```

### 3. Common Atopile Patterns
```ato
# Import components
from "generics/resistors.ato" import Resistor

# Create modules
module MyCircuit:
    # Declare components
    r1 = new Resistor
    
    # Set parameters
    r1.resistance = 10kohm +/- 5%
    r1.package = "0603"
    
    # Make connections
    # (connect interfaces with ~)
    
    # Add constraints
    assert r1.power < 0.25W
```

### 4. Editor Integration (Zed)
- Open the project in Zed
- Benefit from syntax highlighting for `.ato` files
- Use built-in tasks (`Cmd+Shift+P` → "Tasks")
- Automatic formatting on save

### 5. Version Control
```bash
# Initialize git (if not already done)
git init
git add .
git commit -m "Initial atopile project setup"

# Before committing changes
make commit-check
```

## 🔧 Troubleshooting

### Common Issues

**Build Fails:**
```bash
make lint        # Check for syntax errors
make check       # Validate individual files
```

**File Watcher Not Working:**
```bash
brew install fswatch  # Ensure fswatch is installed
```

**KiCAD Won't Open:**
- Install KiCAD from [kicad.org](https://www.kicad.org)
- Ensure it's in your PATH

**Missing Dependencies:**
```bash
make install     # Install project dependencies
ato sync         # Update environment
```

### Debug Commands
```bash
make debug       # Build with verbose output
make info        # Show project status
make test        # Run all validations
```

## 📚 Resources

- **Project Documentation:** `README.md`
- **Atopile Docs:** [atopile.io/getting-started](https://atopile.io/getting-started)
- **Package Registry:** [packages.atopile.io](https://packages.atopile.io)
- **Community:** [Discord](https://discord.gg/atopile)

## 🎯 Pro Tips

1. **Use the file watcher** (`make watch`) for rapid development
2. **Run linting frequently** (`make lint`) to catch issues early
3. **Commit often** with `make commit-check` before each commit
4. **Document your circuits** with docstrings in your `.ato` files
5. **Use version control** for all your designs

## ✅ Verification

Your setup is working correctly if:
- `make build` completes successfully ✅
- `make lint` passes all checks ✅
- `make test` runs without errors ✅
- File watching works with `make watch` 🎯

## 🚀 Ready to Design!

You're all set to start designing circuits with code! 

Begin by editing `main.ato` and running `make watch` to see your changes build automatically.

Happy circuit designing! 🔌✨