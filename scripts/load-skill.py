#!/usr/bin/env python3
"""
Claude Skills Collection - Skill Loader
========================================

This script helps you quickly access and copy skill content for use with Claude.

Usage:
    python load-skill.py list                    # List all available skills
    python load-skill.py show <skill-name>       # Display a skill's content
    python load-skill.py copy <skill-name>       # Copy skill to clipboard
    python load-skill.py search <keyword>        # Search skills by keyword

Examples:
    python load-skill.py list
    python load-skill.py show swiftui-programming-skill
    python load-skill.py copy ios-accessibility-skill
    python load-skill.py search "memory leak"
"""

import os
import sys
import subprocess
from pathlib import Path
from typing import List, Dict, Optional

# ANSI color codes for terminal output
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def get_repo_root() -> Path:
    """Get the repository root directory."""
    script_dir = Path(__file__).parent
    return script_dir.parent


def get_all_skills() -> List[Dict[str, str]]:
    """Scan repository for all skill directories and metadata."""
    repo_root = get_repo_root()
    skills = []

    for item in repo_root.iterdir():
        if item.is_dir() and item.name.endswith('-skill'):
            skill_md = item / "SKILL.md"
            if skill_md.exists():
                # Read frontmatter
                metadata = parse_frontmatter(skill_md)
                skills.append({
                    'directory': item.name,
                    'path': str(skill_md),
                    'name': metadata.get('name', item.name),
                    'description': metadata.get('description', 'No description'),
                    'version': metadata.get('version', '1.0'),
                    'activation': metadata.get('activation', '')
                })

    return sorted(skills, key=lambda x: x['name'])


def parse_frontmatter(skill_path: Path) -> Dict[str, str]:
    """Parse YAML frontmatter from SKILL.md file."""
    metadata = {}
    in_frontmatter = False

    with open(skill_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line == '---':
                if not in_frontmatter:
                    in_frontmatter = True
                else:
                    break
            elif in_frontmatter and ':' in line:
                key, value = line.split(':', 1)
                metadata[key.strip()] = value.strip()

    return metadata


def list_skills():
    """List all available skills with descriptions."""
    skills = get_all_skills()

    print(f"\n{Colors.BOLD}{Colors.HEADER}Claude Skills Collection{Colors.ENDC}")
    print(f"{Colors.CYAN}{'='*80}{Colors.ENDC}\n")

    for i, skill in enumerate(skills, 1):
        print(f"{Colors.BOLD}{i}. {skill['name']}{Colors.ENDC}")
        print(f"   {Colors.CYAN}Directory:{Colors.ENDC} {skill['directory']}")
        print(f"   {Colors.GREEN}Description:{Colors.ENDC} {skill['description']}")
        print(f"   {Colors.YELLOW}Version:{Colors.ENDC} {skill['version']}")
        print()

    print(f"{Colors.CYAN}{'='*80}{Colors.ENDC}")
    print(f"Total skills: {len(skills)}\n")


def show_skill(skill_name: str):
    """Display the content of a skill."""
    skill_path = find_skill_path(skill_name)

    if not skill_path:
        print(f"{Colors.RED}Error: Skill '{skill_name}' not found.{Colors.ENDC}")
        print(f"Use '{Colors.CYAN}python load-skill.py list{Colors.ENDC}' to see available skills.")
        return

    with open(skill_path, 'r', encoding='utf-8') as f:
        content = f.read()

    print(f"\n{Colors.BOLD}{Colors.HEADER}Skill Content:{Colors.ENDC} {skill_name}")
    print(f"{Colors.CYAN}{'='*80}{Colors.ENDC}\n")
    print(content)
    print(f"\n{Colors.CYAN}{'='*80}{Colors.ENDC}\n")


def copy_to_clipboard(skill_name: str):
    """Copy skill content to clipboard."""
    skill_path = find_skill_path(skill_name)

    if not skill_path:
        print(f"{Colors.RED}Error: Skill '{skill_name}' not found.{Colors.ENDC}")
        return

    with open(skill_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Try to copy to clipboard
    try:
        if sys.platform == 'darwin':  # macOS
            subprocess.run(['pbcopy'], input=content.encode(), check=True)
        elif sys.platform == 'linux':
            subprocess.run(['xclip', '-selection', 'clipboard'], input=content.encode(), check=True)
        elif sys.platform == 'win32':
            subprocess.run(['clip'], input=content.encode(), check=True)

        print(f"{Colors.GREEN}✓{Colors.ENDC} Skill content copied to clipboard!")
        print(f"{Colors.CYAN}Paste it into your Claude conversation to activate the skill.{Colors.ENDC}")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print(f"{Colors.YELLOW}Warning: Could not copy to clipboard automatically.{Colors.ENDC}")
        print(f"{Colors.CYAN}Manual copy: cat {skill_path} | pbcopy{Colors.ENDC}")


def search_skills(keyword: str):
    """Search skills by keyword in name, description, or activation."""
    skills = get_all_skills()
    keyword_lower = keyword.lower()

    matches = [
        skill for skill in skills
        if keyword_lower in skill['name'].lower()
        or keyword_lower in skill['description'].lower()
        or keyword_lower in skill['activation'].lower()
    ]

    if not matches:
        print(f"{Colors.YELLOW}No skills found matching '{keyword}'.{Colors.ENDC}")
        return

    print(f"\n{Colors.BOLD}{Colors.HEADER}Search Results for '{keyword}':{Colors.ENDC}")
    print(f"{Colors.CYAN}{'='*80}{Colors.ENDC}\n")

    for skill in matches:
        print(f"{Colors.BOLD}{skill['name']}{Colors.ENDC}")
        print(f"   {Colors.CYAN}Directory:{Colors.ENDC} {skill['directory']}")
        print(f"   {Colors.GREEN}Description:{Colors.ENDC} {skill['description']}")
        print()

    print(f"{Colors.CYAN}Found {len(matches)} matching skill(s).{Colors.ENDC}\n")


def find_skill_path(skill_name: str) -> Optional[Path]:
    """Find the SKILL.md path for a given skill name."""
    repo_root = get_repo_root()

    # Try exact directory match
    skill_dir = repo_root / skill_name
    if skill_dir.exists() and (skill_dir / "SKILL.md").exists():
        return skill_dir / "SKILL.md"

    # Try adding -skill suffix
    if not skill_name.endswith('-skill'):
        skill_dir = repo_root / f"{skill_name}-skill"
        if skill_dir.exists() and (skill_dir / "SKILL.md").exists():
            return skill_dir / "SKILL.md"

    # Try fuzzy match on skill names
    skills = get_all_skills()
    for skill in skills:
        if skill_name.lower() in skill['name'].lower():
            return Path(skill['path'])

    return None


def print_usage():
    """Print usage information."""
    print(__doc__)


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print_usage()
        sys.exit(1)

    command = sys.argv[1].lower()

    if command == 'list':
        list_skills()
    elif command == 'show' and len(sys.argv) >= 3:
        show_skill(sys.argv[2])
    elif command == 'copy' and len(sys.argv) >= 3:
        copy_to_clipboard(sys.argv[2])
    elif command == 'search' and len(sys.argv) >= 3:
        search_skills(' '.join(sys.argv[2:]))
    else:
        print_usage()
        sys.exit(1)


if __name__ == '__main__':
    main()
