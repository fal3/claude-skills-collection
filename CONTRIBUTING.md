# Contributing

We welcome contributions to this Swift/iOS skills collection for Claude Code and Codex.

## Guidelines

1. **Fork and Pull Request**: Fork the repository, make your changes, and submit a pull request with a clear description of what you've added or fixed.

2. **Code Standards**: Ensure all code examples and snippets follow Apple's Swift and iOS development guidelines. Use proper Swift conventions and best practices.

3. **Documentation**: Update SKILL.md and README.md files as necessary to reflect changes. Provide clear, concise instructions and examples.

4. **Testing**: Test your examples and code snippets to ensure they work correctly and demonstrate best practices. State the minimum Swift, Xcode, and platform versions required by version-specific APIs.

5. **New Skills**: Use a lowercase kebab-case directory name. Include `SKILL.md` frontmatter with only `name` and a trigger-rich `description`, a user-facing `README.md`, portable `agents/openai.yaml` metadata, and practical content in `examples/`, `docs/`, or `references/`.

6. **Repository Indexes**: When adding, removing, or renaming a skill, update the inventories or structural guidance in `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, and `README.md`, plus plugin metadata when relevant.

7. **Compatibility**: Do not rename a published skill directory without documenting a migration path for existing installations and references.

8. **Issues**: Report bugs or suggest features via GitHub issues.

9. **Validation**: Run `ruby scripts/validate_skills.rb`, `bash scripts/typecheck_examples.sh`, and `git diff --check` before submitting.

Thank you for contributing to better Swift and iOS development workflows!
