#!/bin/bash

# Claude iOS Skills Distribution Script
# This script provides multiple ways to distribute and install iOS skills

set -e

echo "🍎 Claude iOS Skills Collection - Distribution Helper"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/fal3/claude-skills-collection"
RAW_BASE_URL="https://raw.githubusercontent.com/fal3/claude-skills-collection/main"
SKILLS_DIR="$HOME/.claude/skills"

# Available skills
SKILLS=(
    "swiftui-programming-skill"
    "swift-modern-architecture-skill"
    "ios-accessibility-skill"
    "swift-performance-optimization-skill"
    "cross-platform-app-development-skill"
    "swift-unit-testing-skill"
    "ios-animation-graphics-skill"
    "memory-leak-diagnosis-skill"
)

# Create skills directory
create_skills_dir() {
    if [ ! -d "$SKILLS_DIR" ]; then
        mkdir -p "$SKILLS_DIR"
        echo -e "${GREEN}✅ Created skills directory: $SKILLS_DIR${NC}"
    fi
}

# Download a skill
download_skill() {
    local skill_name=$1
    local skill_url="$RAW_BASE_URL/$skill_name/SKILL.md"
    local skill_file="$SKILLS_DIR/$skill_name.md"
    
    echo -e "${BLUE}📥 Downloading $skill_name...${NC}"
    
    if curl -fsSL "$skill_url" -o "$skill_file"; then
        echo -e "${GREEN}✅ Successfully installed $skill_name${NC}"
        echo -e "${YELLOW}📍 Location: $skill_file${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to download $skill_name${NC}"
        return 1
    fi
}

# Copy skill to clipboard
copy_skill() {
    local skill_name=$1
    local skill_file="$SKILLS_DIR/$skill_name.md"
    
    if [ ! -f "$skill_file" ]; then
        echo -e "${YELLOW}⚠️  Skill not installed locally. Downloading first...${NC}"
        if ! download_skill "$skill_name"; then
            return 1
        fi
    fi
    
    if command -v pbcopy >/dev/null 2>&1; then
        # macOS
        cat "$skill_file" | pbcopy
        echo -e "${GREEN}✅ Skill copied to clipboard!${NC}"
    elif command -v xclip >/dev/null 2>&1; then
        # Linux
        cat "$skill_file" | xclip -selection clipboard
        echo -e "${GREEN}✅ Skill copied to clipboard!${NC}"
    elif command -v clip >/dev/null 2>&1; then
        # Windows
        cat "$skill_file" | clip
        echo -e "${GREEN}✅ Skill copied to clipboard!${NC}"
    else
        echo -e "${YELLOW}⚠️  Clipboard not available. Showing content:${NC}"
        cat "$skill_file"
    fi
}

# List available skills
list_skills() {
    echo -e "${BLUE}Available iOS Skills:${NC}"
    echo ""
    for skill in "${SKILLS[@]}"; do
        echo -e "  • ${GREEN}$skill${NC}"
    done
    echo ""
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [SKILL_NAME]"
    echo ""
    echo "Commands:"
    echo "  list                    List all available skills"
    echo "  install <skill-name>    Install a specific skill"
    echo "  copy <skill-name>       Copy skill to clipboard"
    echo "  install-all            Install all skills"
    echo "  help                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 install swiftui-programming-skill"
    echo "  $0 copy ios-accessibility-skill"
    echo "  $0 install-all"
    echo ""
    echo "After installation, skills are available at: $SKILLS_DIR"
    echo ""
    echo "Alternative installation methods:"
    echo "  • NPM: npm install -g claude-ios-skills"
    echo "  • NPX: npx claude-ios-skills list"
    echo "  • Web: Open web/index.html in your browser"
}

# Main script logic
case "${1:-help}" in
    "list")
        list_skills
        ;;
    "install")
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Please specify a skill name${NC}"
            list_skills
            exit 1
        fi
        create_skills_dir
        download_skill "$2"
        ;;
    "copy")
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Please specify a skill name${NC}"
            list_skills
            exit 1
        fi
        create_skills_dir
        copy_skill "$2"
        ;;
    "install-all")
        create_skills_dir
        echo -e "${BLUE}📦 Installing all iOS skills...${NC}"
        echo ""
        for skill in "${SKILLS[@]}"; do
            download_skill "$skill"
            echo ""
        done
        echo -e "${GREEN}🎉 All skills installed successfully!${NC}"
        echo -e "${YELLOW}📍 Location: $SKILLS_DIR${NC}"
        ;;
    "help"|*)
        show_usage
        ;;
esac
