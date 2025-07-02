# Zed Editor Configuration for Atopile Development

This directory contains Zed editor configuration files for optimal atopile circuit design development.

## Files

- `settings.json` - Editor settings and language configuration
- `tasks.json` - Project-specific tasks for atopile development
- `README.md` - This documentation file

## Using Zed Tasks

Zed tasks provide quick access to common atopile commands directly from the editor.

### Running Tasks

1. **Open Command Palette**: `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Linux/Windows)
2. **Type**: `task: spawn`
3. **Select**: Choose from available tasks
4. **Run**: Press `Enter` or `Opt+Enter`

### Quick Shortcuts

- `Opt+Shift+T` - Open task spawn menu
- `Opt+T` - Rerun last task

### Available Tasks

#### Build & Development
- **Build atopile project** - Compile the circuit design
- **Build and open KiCAD** - Build and launch KiCAD with the PCB
- **Debug build (verbose)** - Build with detailed output
- **Start file watcher** - Auto-build on file changes

#### Validation & Quality
- **Validate atopile file** - Check syntax of current file
- **Validate current file** - Quick validation with auto-hide
- **Run linting checks** - Full project quality analysis
- **Run linting with fixes** - Lint and auto-fix issues
- **Run all tests** - Complete validation suite

#### Project Management
- **Install dependencies** - Sync project dependencies
- **Clean build artifacts** - Remove generated files
- **View project info** - Show project status
- **Open PCB in KiCAD** - Launch KiCAD with current PCB

#### Component Management
- **Create new part** - Add components to project
- **Show atopile help** - Display atopile CLI help

### Task Tags

Tasks are organized with tags for easy filtering:

- `build` - Building and compilation tasks
- `validate` - Syntax and validation tasks
- `lint` - Code quality tasks
- `kicad` - KiCAD integration tasks
- `watch` - File watching tasks
- `dev` - Development workflow tasks
- `clean` - Cleanup tasks
- `install` - Dependency management
- `test` - Testing and validation
- `help` - Documentation tasks

### Environment Variables

Zed provides these variables for tasks:

- `${ZED_WORKTREE_ROOT}` - Project root directory
- `${ZED_FILE}` - Current file path
- `${ZED_ROW}` - Cursor row position
- `${ZED_COLUMN}` - Cursor column position
- `${ZED_SELECTED_TEXT}` - Currently selected text

## Language Configuration

### Atopile File Support

- **File Extension**: `.ato` files are recognized as atopile
- **Tab Size**: 4 spaces (follows Python conventions)
- **Line Length**: 88 characters (recommended)
- **Format on Save**: Enabled
- **Soft Wrap**: At preferred line length

### Editor Features

- **Syntax Highlighting**: Basic support for `.ato` files
- **Indentation Guides**: Enabled for better code structure
- **Git Integration**: Status indicators and gutter
- **Wrap Guides**: Visual line length indicator

## Workflow Tips

### Development Workflow

1. **Start with file watcher**: Run "Start file watcher" task
2. **Edit in Zed**: Make changes to `.ato` files
3. **Auto-build**: Watcher automatically builds on save
4. **Validate**: Use "Validate current file" for quick checks
5. **Lint**: Run "Run linting checks" before committing

### Quick Validation

1. Open `.ato` file in Zed
2. `Opt+Shift+T` → "Validate current file"
3. Fix any issues shown in terminal
4. Task auto-hides on success

### KiCAD Integration

1. **Build first**: Use "Build atopile project"
2. **Open PCB**: Use "Build and open KiCAD" or "Open PCB in KiCAD"
3. **Iterate**: Make changes in Zed, rebuild, refresh in KiCAD

## Customization

### Adding New Tasks

Edit `.zed/tasks.json` and add new task objects:

```json
{
  "label": "My Custom Task",
  "command": "echo",
  "args": ["Hello from ${ZED_FILE}"],
  "use_new_terminal": false,
  "reveal": "always",
  "tags": ["custom"]
}
```

### Task Options

- `use_new_terminal`: Create new terminal tab
- `allow_concurrent_runs`: Allow multiple instances
- `reveal`: Control terminal visibility ("always", "no_focus", "never")
- `hide`: Auto-hide behavior ("never", "always", "on_success")
- `cwd`: Working directory
- `env`: Environment variables

### Language Settings

Modify `.zed/settings.json` to customize:

```json
{
  "languages": {
    "atopile": {
      "tab_size": 2,
      "preferred_line_length": 100,
      "format_on_save": "off"
    }
  }
}
```

## Troubleshooting

### Tasks Not Appearing
- Ensure `.zed/tasks.json` has valid JSON syntax
- Restart Zed if tasks don't load
- Check terminal output for error messages

### Commands Not Found
- Verify atopile is installed: `ato --version`
- Check script permissions: `chmod +x scripts/*.sh`
- Ensure you're in project root directory

### File Validation Issues
- Make sure file paths are correct
- Check that `.ato` files have proper syntax
- Use "Debug build (verbose)" for detailed error info

## Resources

- [Zed Tasks Documentation](https://zed.dev/docs/tasks)
- [Atopile Documentation](https://atopile.io/getting-started/)
- [Project Makefile](../Makefile) - Alternative command interface
- [Project README](../README.md) - Complete development guide