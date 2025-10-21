#!/bin/bash

# Setup script to configure repository URLs
# Run this once after cloning to update all URLs with your GitHub username

set -e

echo "🔧 Claude Skills Collection Setup"
echo ""

# Get GitHub username from git remote
if git config --get remote.origin.url > /dev/null 2>&1; then
    GIT_URL=$(git config --get remote.origin.url)
    # Extract username from various URL formats
    if [[ $GIT_URL =~ github\.com[:/]([^/]+)/ ]]; then
        USERNAME="${BASH_REMATCH[1]}"
        echo "✅ Detected GitHub username: $USERNAME"
    else
        echo "⚠️  Could not auto-detect username from: $GIT_URL"
        read -p "Enter your GitHub username: " USERNAME
    fi
else
    read -p "Enter your GitHub username: " USERNAME
fi

echo ""
echo "📝 Updating URLs in README.md..."

# Update all instances of <YOUR-USERNAME> in README
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/<YOUR-USERNAME>/$USERNAME/g" README.md
else
    # Linux
    sed -i "s/<YOUR-USERNAME>/$USERNAME/g" README.md
fi

echo "✅ Setup complete!"
echo ""
echo "Your installation commands are now ready to use."
echo "Example:"
echo "  curl -fsSL https://raw.githubusercontent.com/$USERNAME/claude-skills-collection/main/swiftui-programming-skill/SKILL.md -o ~/.claude/skills/swiftui-programming-skill.md"
echo ""
echo "Don't forget to commit the updated README.md!"
