# DIY Circuit Design with Atopile

A personal collection of DIY circuit designs using the atopile hardware design language.

## 🚀 Quick Start

### Prerequisites
- macOS (recommended) or Linux
- [Homebrew](https://brew.sh/) (for macOS)
- [KiCAD](https://www.kicad.org/download/) (for PCB layout)

### Installation
```bash
# Install atopile
brew install atopile/tap/atopile

# Install file watcher (for development)
brew install fswatch

# Setup project
make setup
```

### Basic Usage
```bash
# Build the project
make build

# Start file watcher for automatic builds
make watch

# Run linting and validation
make lint

# Open in KiCAD
make kicad
```

## 🛠 Development Workflow

### Available Commands
- `make help` - Show all available commands
- `make build` - Build the atopile project
- `make watch` - Start file watcher for automatic builds
- `make lint` - Run linting and validation checks
- `make check` - Run atopile validation checks
- `make clean` - Clean build artifacts
- `make kicad` - Build and open KiCAD
- `make test` - Run all tests and validations
- `make dev` - Start development workflow (build + watch)

### Project Structure
```
circuits/
├── ato.yaml          # Project configuration
├── main.ato          # Main circuit definition
├── scripts/          # Development scripts
│   ├── watch.sh      # File watcher script
│   └── lint.sh       # Linting script
├── .zed/             # Zed editor configuration
│   └── settings.json # Language-specific settings
├── build/            # Build artifacts (generated)
├── layouts/          # KiCAD layout files (generated)
└── Makefile          # Development commands
```

## 📝 Circuit Design

### Writing Atopile Code
Atopile uses `.ato` files to describe circuits with code. Here's a simple example:

```ato
"""LED blinker circuit"""
import Resistor from "generics/resistor.ato"
import LED from "generics/led.ato"

module LEDBlinker:
    power = new ElectricPower
    led = new LED
    resistor = new Resistor
    
    # Connect components
    power.hv ~ resistor.p1
    resistor.p2 ~ led.anode
    led.cathode ~ power.lv
    
    # Set parameters
    resistor.resistance = 330ohm +/- 10%
    led.color = "red"
```

### Key Concepts
- **Modules**: Reusable circuit blocks (like classes in programming)
- **Interfaces**: Define connection points (Electrical, ElectricPower, I2C, etc.)
- **Parameters**: Values with units and tolerances (resistance, voltage, etc.)
- **Connections**: Use `~` to connect interfaces
- **Assertions**: Validate design constraints with `assert`

### Adding Components
```bash
# Search and add a specific part by LCSC number
ato create part --search C12345 --accept-single

# Add a package dependency
ato add atopile/addressable-leds
```

## 🔧 Editor Setup (Zed)

This project is configured for Zed editor with:
- Syntax highlighting for `.ato` files
- Custom formatting settings
- Built-in tasks for common operations
- File watching integration

### Zed Tasks
- `Cmd+Shift+P` → "Tasks: Spawn" → Select build tasks
- Or use keyboard shortcuts as configured

## 🧪 Testing & Validation

### Automated Checks
The linting script runs several checks:
- Configuration file validation
- Syntax checking for all `.ato` files
- Atopile built-in validation
- Common code quality issues
- Dependency verification
- Build testing

### Running Tests
```bash
# Run all checks
make test

# Run linting with fixes
make lint-fix

# Run verbose linting
make lint-verbose

# Pre-commit validation
make commit-check
```

## 📦 Dependencies & Packages

### Package Management
```bash
# Install all dependencies
make install

# Add a new dependency
ato add package-name

# Remove a dependency  
ato remove package-name

# Update dependencies
ato sync
```

### Finding Packages
- [Atopile Package Registry](https://packages.atopile.io)
- [GitHub atopile organization](https://github.com/atopile)

## 🖥 KiCAD Integration

### Workflow
1. Design circuit in `.ato` files
2. Run `make build` to generate netlist
3. Run `make kicad` to open KiCAD with updated layout
4. Place and route components in KiCAD
5. Generate manufacturing files

### Layout Files
- `layouts/default/default.kicad_pcb` - Main PCB layout
- Build artifacts in `build/` directory

## 🔄 File Watching

Start the file watcher for automatic builds on file changes:
```bash
make watch
# or directly:
./scripts/watch.sh
```

The watcher monitors:
- `.ato` files
- `ato.yaml` configuration
- Debounces changes (2-second delay)
- Shows build status with colors

## 🐛 Troubleshooting

### Common Issues
1. **Build fails**: Check syntax with `make lint`
2. **KiCAD won't open**: Ensure KiCAD is installed and in PATH
3. **File watcher not working**: Install fswatch with `brew install fswatch`
4. **Dependencies missing**: Run `make install`

### Debug Mode
```bash
# Build with verbose output
make debug

# Check project status
make info

# Validate configuration
make validate-config
```

## 📚 Learning Resources

- [Atopile Documentation](https://atopile.io/getting-started/)
- [Atopile Tutorial](https://atopile.io/quickstart)
- [Package Registry](https://packages.atopile.io)
- [Community Discord](https://discord.gg/atopile)

## 🤝 Contributing

This is a personal project, but feel free to:
1. Fork the repository
2. Create feature branches
3. Submit pull requests
4. Share your designs!

## 📄 License

This project is open source. Individual circuit designs may have different licenses - check specific files for details.

---

Happy circuit designing! 🔌✨