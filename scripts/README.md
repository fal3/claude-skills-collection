# Skills Automation Scripts

This directory contains optional automation tools to enhance your Claude Skills Collection experience.

## load-skill.py

A Python CLI tool to quickly access, search, and copy skill content.

### Prerequisites

- Python 3.6+ installed
- For clipboard support:
  - **macOS**: Built-in (uses `pbcopy`)
  - **Linux**: Install `xclip` (`sudo apt-get install xclip`)
  - **Windows**: Built-in (uses `clip`)

### Installation

Make the script executable (macOS/Linux):
```bash
chmod +x scripts/load-skill.py
```

### Usage

#### List All Skills
```bash
python scripts/load-skill.py list
```

Output:
```
Claude Skills Collection
================================================================================

1. Cross-Platform App Development Skill
   Directory: cross-platform-app-development-skill
   Description: Strategies for developing apps that work across multiple Apple platforms
   Version: 1.0

2. iOS Accessibility Skill
   Directory: ios-accessibility-skill
   Description: Best practices for implementing accessibility features in iOS apps
   Version: 1.0
...
```

#### Show Skill Content
```bash
python scripts/load-skill.py show swiftui-programming-skill
```

#### Copy Skill to Clipboard
```bash
python scripts/load-skill.py copy ios-accessibility-skill
```

Then paste directly into your Claude conversation!

#### Search Skills
```bash
python scripts/load-skill.py search "memory leak"
python scripts/load-skill.py search "animation"
python scripts/load-skill.py search "SwiftUI"
```

### Tips

**Quick Access Alias (macOS/Linux):**
Add to your `~/.bashrc` or `~/.zshrc`:
```bash
alias skill='python /path/to/claude-skills-collection/scripts/load-skill.py'
```

Then use:
```bash
skill list
skill copy swiftui-programming-skill
skill search "accessibility"
```

**Windows PowerShell:**
Create an alias in your PowerShell profile:
```powershell
function Skill { python C:\path\to\claude-skills-collection\scripts\load-skill.py $args }
```

### Troubleshooting

**Clipboard not working?**
- Ensure the clipboard utility is installed for your OS
- Manually copy using: `cat skill-directory/SKILL.md | pbcopy` (macOS)

**Python not found?**
- Install Python from [python.org](https://python.org)
- Or use system Python: `python3` instead of `python`

**Skill not found?**
- Use `list` command to see available skills
- Try fuzzy matching: `show swiftui` instead of full name
- Add `-skill` suffix: `show swiftui-programming-skill`

## Future Scripts

We're planning to add:
- `skill-validator.py` - Validate SKILL.md files for syntax errors
- `skill-generator.py` - Interactive wizard to create new skills
- `skill-exporter.py` - Export skills to different formats (PDF, HTML)

Contributions welcome! See [../CONTRIBUTING.md](../CONTRIBUTING.md)
