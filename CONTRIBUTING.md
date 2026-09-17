# Contributing

This collection provides Swift and Apple development guidance for coding agents. Read [AGENTS.md](AGENTS.md) before making changes.

## Guidelines

1. **Fork and Pull Request**: Fork the repository, make your changes, and submit a pull request with a clear description of what you've added or fixed.

2. **Code Standards**: Ensure all code examples and snippets follow Apple's Swift and iOS development guidelines. Use proper Swift conventions and best practices.

3. **Documentation**: Update SKILL.md and README.md files as necessary to reflect changes. Provide clear, concise instructions and examples.

4. **Testing**: Test your examples and code snippets to ensure they work correctly and demonstrate best practices. State the minimum Swift, Xcode, and platform versions required by version-specific APIs.

5. **New Skills**: Use a lowercase kebab-case directory name. Include `SKILL.md` frontmatter with only `name` and a trigger-rich `description`, a user-facing `README.md`, optional host UI metadata in `agents/openai.yaml`, and practical content in `examples/`, `docs/`, or `references/`.

6. **Repository Indexes**: When adding, removing, or renaming a skill, update the inventories or structural guidance in `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, and `README.md`, plus plugin metadata when relevant.

7. **Compatibility**: Do not rename a published skill directory without documenting a migration path for existing installations and references.

8. **Host independence**: Keep core procedures usable by any agent with file access. Put host-specific setup in [the compatibility guide](docs/agent-compatibility.md). Preserve source identifiers and use the installer to normalize copied packages for strict hosts.

9. **Issues**: Report bugs or suggest features via GitHub issues.

10. **Validation**: Run `python3 -m unittest discover -s tests -p 'test_*.py'`, `ruby scripts/validate_skills.rb`, and `git diff --check` before submitting. Run `bash scripts/typecheck_examples.sh` when Swift examples change. Apple example checks require the declared Apple toolchain; installer tests run on Python 3.9 or later on macOS, Linux, and Windows.

For a new or changed skill, try its matching and unrelated prompts in an available coding agent. Report which host you tried and whether the skill was discovered and activated. Structural validation alone does not establish host behavior.
