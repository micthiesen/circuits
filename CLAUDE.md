# CircuitScript Project Guide for AI Agents

## Overview

This project contains CircuitScript circuits for DIY electronics. As an AI agent, you'll primarily be asked to create new CircuitScript projects or modify existing ones. This guide provides everything you need to work effectively with CircuitScript.

## Project Structure

```
circuits/
├── projects/           # CircuitScript project files (.cst)
├── output/            # Generated SVG/PDF files
├── scripts/           # Build and development tools
├── circuitscript-docs/# Complete CircuitScript documentation
└── .zed/              # Zed editor tasks
```

## Quick Start

### 1. Creating a New Project

Create a new `.cst` file in the `projects/` directory:

```bash
# Example: projects/led-blinker.cst
```

All CircuitScript files must:
- Start with `import lib`
- Be saved as `.cst` files in `projects/`
- Follow CircuitScript syntax (see documentation below)

### 2. Testing Your Code

**ALWAYS use `build-agent.sh` to test syntax after making changes:**

```bash
scripts/build-agent.sh your-project-name
```

This script:
- Uses consistent Node.js version via NVM
- Shows all errors (stdout + stderr combined)
- Returns exit code 0 for success, 1 for failure
- Generates compact, parseable output

**Example successful output:**
```
Building led-blinker...
Generated file /path/to/output/led-blinker.svg
SUCCESS: led-blinker built successfully
```

**Example error output:**
```
Building led-blinker...
SyntaxError: Unexpected token 'res' on line 8
FAILED: Exit code 1
```

### 3. Other Available Scripts

- `scripts/build.sh <project>` - Full build (SVG + PDF) with fancy output
- `scripts/watch.sh <project> [svg|pdf]` - File watching for development
- `scripts/build-current.sh <file-path>` - Extract project name from file path
- `scripts/watch-current.sh <file-path> [format]` - Watch specific file

## CircuitScript Basics

### Essential Patterns

**Basic circuit structure:**
```circuitscript
import lib

# Power supplies
vcc = supply("VCC")
gnd = dgnd()

# Simple LED circuit
at vcc
wire down 100 right 100
add res(220, "R1")
wire right 100 down 50
add led("red", "D1")
wire down 50
to gnd
```

**Key commands:**
- `at <node>` - Set current position
- `wire <direction> <distance>` - Draw wire
- `add <component>` - Add component
- `to <node>` - Connect to destination
- `branch:` - Create branch in circuit
- `net("name")` - Create named net

**Common components:**
- `supply("3V3")` - Voltage supply
- `dgnd()` - Digital ground
- `res(10k)` - Resistor
- `cap(100n)` - Capacitor
- `led("color")` - LED
- `create component:` - Custom component

### Circuit Navigation

**Wire directions and distances:**
```circuitscript
wire down 100      # Move down 100 units
wire right 50      # Move right 50 units
wire up 75 left 25 # Move up 75, then left 25
```

**Branching:**
```circuitscript
at vcc
wire down 100

branch:
    wire right 100
    add res(1k)
    wire right 100
    to gnd

branch:
    wire left 100
    add led("green")
    wire left 100
    to gnd
```

### Component Parameters

```circuitscript
# Set parameters during creation
my_res = res(10k)
my_res.place = true
my_res.mpn = "RESISTOR-123"
my_res.footprint = "0805"

# Or use double-dot operator
add res(220)
..value = "220R"
..footprint = "0603"
```

## Documentation Resources

### Primary Documentation
The complete CircuitScript documentation is in `circuits/circuitscript-docs/docs/` as markdown files.

**Search the docs first with grep:**
```bash
grep -r "your-search-term" circuits/circuitscript-docs/docs/**/*.md
```

**Key documentation files:**
- `getting-started.md` - Basic tutorial
- `building-circuits/creating-components.md` - Custom components
- `building-circuits/component-parameters.md` - Component configuration
- `building-circuits/coordinate-system.md` - Positioning and angles
- `building-circuits/output-formats.md` - SVG, PDF, KiCAD output
- `language/` - Complete language reference

### Common Patterns to Search For

**Components:** `grep -r "res\|cap\|led\|supply" docs/**/*.md`
**Wiring:** `grep -r "wire\|at\|to\|branch" docs/**/*.md`
**Advanced:** `grep -r "create component\|module\|import" docs/**/*.md`

## Development Workflow

### 1. Research Phase
```bash
# Search existing documentation first
grep -r "relevant-concept" circuits/circuitscript-docs/docs/**/*.md

# Look at existing project for reference
cat circuits/projects/fogger.cst
```

### 2. Implementation Phase
```bash
# Create new project file
touch circuits/projects/your-project.cst

# Edit the file with CircuitScript code
# Always start with: import lib

# Test frequently
scripts/build-agent.sh your-project
```

### 3. Iteration Phase
```bash
# After each change, verify syntax
scripts/build-agent.sh your-project

# For development with auto-rebuild
scripts/watch.sh your-project svg
```

## Example Projects

### Simple LED Circuit
```circuitscript
import lib

# Power supplies
v3v3 = supply("3V3")
gnd = dgnd()

# Basic LED with current limiting resistor
at v3v3
wire right 100
add res(220, "R1")
wire right 100 down 50
add led("green", "D1")
wire down 50
to gnd
```

### Multiple Components with Branching
```circuitscript
import lib

vcc = supply("5V")
gnd = dgnd()

at vcc
wire down 100

# Branch for LED circuit
branch:
    wire right 150
    add res(330, "R1")
    wire right 100 down 50
    add led("red", "D1")
    wire down 50
    to gnd

# Branch for sensor pull-up
branch:
    wire left 150
    add res(10k, "R2")
    sensor_input = net("SENSOR")
    wire left 100
    add sensor_input
    wire down 100
    to gnd
```

### Custom Component
```circuitscript
import lib

# Create custom MOSFET component
mosfet = create component:
    pins: 3
    type: "mosfet"
    params:
        device: "NFET"
        footprint: "SOT-23"

vcc = supply("12V")
gnd = dgnd()

# Use the custom component
at vcc
wire down 100
add mosfet
mosfet.source to gnd
```

## Common Issues and Solutions

### Syntax Errors
- **Always start with `import lib`**
- **Use proper indentation for blocks**
- **Check component names and parameters**
- **Verify wire directions and distances**

### Build Failures
- **Run `scripts/build-agent.sh` after every change**
- **Check that project file exists in `projects/`**
- **Ensure CircuitScript CLI is installed: `npm install -g circuitscript`**

### Component Issues
- **Use built-in components: `res()`, `cap()`, `led()`, `supply()`, `dgnd()`**
- **For custom components, define pins and type properly**
- **Set required parameters like footprint for PCB output**

## Output Formats

CircuitScript generates multiple output formats:

- **SVG** - Vector graphics for web/display
- **PDF** - Printable schematics with multi-page support
- **KiCAD netlist** - For PCB layout (requires footprint parameters)

**Format is determined by file extension:**
```bash
circuitscript input.cst output.svg   # SVG
circuitscript input.cst output.pdf   # PDF
circuitscript input.cst output.net   # KiCAD netlist
```

## Best Practices for Agents

### 1. Always Test Early and Often
```bash
# After writing any CircuitScript code
scripts/build-agent.sh your-project
```

### 2. Use Descriptive Names
```circuitscript
# Good
current_limit_resistor = res(220, "R1")
status_led = led("green", "D1")

# Avoid
r1 = res(220)
d1 = led("green")
```

### 3. Add Comments
```circuitscript
# Power supply section
vcc = supply("5V")   # Main 5V rail
gnd = dgnd()         # Digital ground

# LED indicator circuit
at vcc
wire down 100        # Drop down from power rail
add res(330, "R1")   # Current limiting resistor
```

### 4. Structure Complex Circuits
```circuitscript
import lib

# Power supplies
vcc = supply("5V")
gnd = dgnd()

# Define components first
led_resistor = res(330, "R1")
status_led = led("green", "D1")

# Build circuit
at vcc
wire down 100
add led_resistor
wire down 50
add status_led
wire down 50
to gnd
```

### 5. Handle Errors Gracefully
- **Always check build output for syntax errors**
- **Read error messages carefully - they often point to specific lines**
- **Start simple and add complexity gradually**
- **Use existing projects as reference patterns**

## Zed Editor Integration

If using Zed editor, these tasks are pre-configured in `.zed/tasks.json`:

- **"Build Current Project"** - Builds the currently open `.cst` file
- **"Watch Current Project (SVG)"** - Auto-rebuilds SVG on file changes
- **"Watch Current Project (PDF)"** - Auto-rebuilds PDF on file changes

Access via Command Palette (`Cmd+Shift+P`) → search for task name.

## Remember

1. **Always start with `import lib`**
2. **Test with `scripts/build-agent.sh` after every change**
3. **Search the documentation first: `grep -r "term" circuits/circuitscript-docs/docs/**/*.md`**
4. **Use the existing `fogger.cst` project as a reference**
5. **Build incrementally - start simple, add complexity**
6. **Read error messages carefully - they usually point to the exact issue**

Happy circuit designing! 🔌⚡