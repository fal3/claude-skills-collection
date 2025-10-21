#!/bin/bash

# Claude Skills Collection Installer
# Usage: bash install.sh <skill-name>

set -e

SKILL_NAME=$1
INSTALL_DIR="$HOME/.claude/skills"

# Auto-detect repository URL from git remote or use fallback
if git rev-parse --git-dir > /dev/null 2>&1; then
    # We're in a git repo, get the remote URL
    GIT_URL=$(git config --get remote.origin.url)
    # Convert git@ to https:// format
    GIT_URL=${GIT_URL/git@github.com:/https://github.com/}
    GIT_URL=${GIT_URL/.git/}
    # Extract username/repo
    REPO_PATH=$(echo $GIT_URL | sed 's|https://github.com/||')
    REPO_URL="https://raw.githubusercontent.com/$REPO_PATH/main"
else
    # Fallback: download script with repo path as parameter
    # Usage: curl ... | bash -s <skill-name> <github-user/repo>
    if [ -n "$2" ]; then
        REPO_URL="https://raw.githubusercontent.com/$2/main"
    else
        echo "❌ Error: Not in a git repository and no repo specified"
        echo "Usage: bash install.sh <skill-name>"
        echo "   OR: curl -fsSL <repo-url>/install.sh | bash -s <skill-name> <github-user/repo>"
        exit 1
    fi
fi

if [ -z "$SKILL_NAME" ]; then
    echo "❌ Error: Please provide a skill name"
    echo "Usage: bash install.sh <skill-name>"
    echo ""
    echo "Available skills:"
    echo "  - swiftui-programming-skill"
    echo "  - swift-modern-architecture-skill"
    echo "  - ios-accessibility-skill"
    echo "  - swift-performance-optimization-skill"
    echo "  - cross-platform-app-development-skill"
    echo "  - swift-unit-testing-skill"
    echo "  - ios-animation-graphics-skill"
    echo "  - memory-leak-diagnosis-skill"
    exit 1
fi

# Create skills directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download the skill file
echo "📥 Downloading $SKILL_NAME..."
curl -fsSL "$REPO_URL/$SKILL_NAME/SKILL.md" -o "$INSTALL_DIR/$SKILL_NAME.md"

if [ $? -eq 0 ]; then
    echo "✅ Successfully installed $SKILL_NAME"
    echo "📍 Location: $INSTALL_DIR/$SKILL_NAME.md"
    echo ""
    echo "To use this skill:"
    echo "  1. Copy the content from: $INSTALL_DIR/$SKILL_NAME.md"
    echo "  2. Paste it into your Claude conversation"
    echo "  3. Start asking questions related to the skill!"
else
    echo "❌ Failed to install $SKILL_NAME"
    echo "Please check the skill name and try again"
    exit 1
fi
