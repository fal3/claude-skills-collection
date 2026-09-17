#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"
require "uri"
require "yaml"

ROOT = Pathname.new(__dir__).parent.expand_path
SKILLS_ROOT = ROOT.join("skills")
MAX_SKILL_LINES = 500

# These names were already published before the portable metadata migration.
# Keep them stable until a separately documented compatibility release changes them.
LEGACY_NAMES = {
  "cross-platform-app-development-skill" => "Cross-Platform App Development Skill",
  "ios-accessibility-skill" => "iOS Accessibility Skill",
  "ios-animation-graphics-skill" => "iOS Animation Graphics Skill",
  "memory-leak-diagnosis-skill" => "Memory Leak Diagnosis Skill",
  "swift-SpeechAnalyzer-Framework-Expert" => "SpeechAnalyzer Framework Expert",
  "swift-modern-architecture-skill" => "Swift Modern Architecture Skill",
  "swift-performance-optimization-skill" => "Swift Performance Optimization Skill",
  "swift-unit-testing-skill" => "Swift Unit Testing Skill",
  "swiftui-programming-skill" => "SwiftUI Programming Skill"
}.freeze

NEW_SKILL_NAMES = %w[
  app-intents-widgets
  swift-concurrency-migration
  swiftdata-core-data-migrations
].freeze

EXPECTED_FOLDERS = (LEGACY_NAMES.keys + NEW_SKILL_NAMES).sort.freeze

EXPECTED_PLUGIN_VERSION = "1.2.0"

def frontmatter_lines(path, errors)
  lines = path.readlines(chomp: true)
  unless lines.first == "---"
    errors << "#{path.relative_path_from(ROOT)} must start with YAML frontmatter"
    return [[], lines]
  end

  closing = lines[1..]&.index("---")
  unless closing
    errors << "#{path.relative_path_from(ROOT)} has unclosed YAML frontmatter"
    return [[], lines]
  end

  [lines[1, closing], lines]
end

def top_level_fields(lines)
  lines.each_with_object([]) do |line, fields|
    match = line.match(/^([A-Za-z][A-Za-z0-9_-]*):(?:\s|$)/)
    fields << match[1] if match
  end
end

def validate_markdown(path, errors)
  text = path.read
  relative = path.relative_path_from(ROOT)

  fence_count = text.lines.count { |line| line.match?(/^\s*(```|~~~)/) }
  errors << "#{relative} has an unclosed fenced code block" if fence_count.odd?

  text.scan(/\[[^\]]*\]\(([^)]+)\)/).flatten.each do |raw_target|
    target = raw_target.strip
    target = target[1...-1] if target.start_with?("<") && target.end_with?(">")
    target = target.sub(/\s+["'].*\z/, "")
    next if target.empty? || target.start_with?("#", "mailto:")
    next if target.match?(%r{\A[a-z][a-z0-9+.-]*://}i)

    target = target.split("#", 2).first.split("?", 2).first
    next if target.nil? || target.empty?

    begin
      target = URI::DEFAULT_PARSER.unescape(target)
    rescue ArgumentError
      errors << "#{relative} contains an invalid link target: #{raw_target}"
      next
    end

    destination = if target.start_with?("/")
                    Pathname.new(target)
                  else
                    path.dirname.join(target).cleanpath
                  end
    errors << "#{relative} links to missing #{target}" unless destination.exist?
  end
end

errors = []
skill_roots = SKILLS_ROOT.children.select(&:directory?).sort_by(&:basename)
actual_folders = skill_roots.map { |root| root.basename.to_s }
unless actual_folders == EXPECTED_FOLDERS
  errors << "skill folders differ from the published #{EXPECTED_FOLDERS.length}-skill inventory (expected #{EXPECTED_FOLDERS.inspect}, found #{actual_folders.inspect})"
end

seen_names = {}
skill_roots.each do |skill_root|
  folder = skill_root.basename.to_s
  skill_file = skill_root.join("SKILL.md")
  readme = skill_root.join("README.md")
  agent_file = skill_root.join("agents", "openai.yaml")
  prompt_file = skill_root.join("examples", "prompts.md")

  unless skill_file.file?
    errors << "skills/#{folder} is missing SKILL.md"
    next
  end
  errors << "skills/#{folder} is missing README.md" unless readme.file?

  frontmatter, all_lines = frontmatter_lines(skill_file, errors)
  fields = top_level_fields(frontmatter)
  errors << "skills/#{folder}/SKILL.md frontmatter must contain exactly name and description (found #{fields.inspect})" unless fields.sort == %w[description name]

  begin
    metadata = YAML.safe_load(
      frontmatter.join("\n"),
      permitted_classes: [],
      permitted_symbols: [],
      aliases: false
    )
  rescue Psych::Exception => error
    errors << "skills/#{folder}/SKILL.md has invalid YAML: #{error.message.lines.first.strip}"
    metadata = {}
  end
  unless metadata.is_a?(Hash)
    errors << "skills/#{folder}/SKILL.md frontmatter must be a mapping"
    metadata = {}
  end

  name = metadata["name"]
  description = metadata["description"]
  expected_name = LEGACY_NAMES.fetch(folder, folder)
  errors << "skills/#{folder} changed published name #{expected_name.inspect} to #{name.inspect}" unless name == expected_name
  if name && seen_names.key?(name)
    errors << "duplicate skill name #{name.inspect} in #{seen_names[name]} and skills/#{folder}"
  elsif name
    seen_names[name] = "skills/#{folder}"
  end

  if description.to_s.empty?
    errors << "skills/#{folder} has an empty description"
  else
    errors << "skills/#{folder} description must state when to use it" unless description.match?(/\buse (?:when|for|to)\b/i)
    negative_boundary = description.match?(/\bdo not (?:use|activate|enable|invent)\b|not for|use .+ instead|instead,? use|avoid (?:using|activating)/i)
    errors << "skills/#{folder} description must state when not to use it" unless negative_boundary
    errors << "skills/#{folder} description exceeds 1,024 characters" if description.length > 1_024
  end

  errors << "skills/#{folder}/SKILL.md has #{all_lines.length} lines; maximum is #{MAX_SKILL_LINES}" if all_lines.length > MAX_SKILL_LINES
  errors << "skills/#{folder}/SKILL.md still contains a TODO placeholder" if skill_file.read.match?(/\[TODO|TODO:/i)

  if prompt_file.file?
    prompt_text = prompt_file.read
    errors << "skills/#{folder}/examples/prompts.md needs a Should activate section" unless prompt_text.match?(/^## Should activate\s*$/i)
    errors << "skills/#{folder}/examples/prompts.md needs a Should not activate section" unless prompt_text.match?(/^## Should not activate\s*$/i)
  else
    errors << "skills/#{folder} is missing examples/prompts.md"
  end

  support_files = %w[examples references docs].flat_map do |directory|
    path = skill_root.join(directory)
    path.directory? ? path.children.select(&:file?) : []
  end
  errors << "skills/#{folder} needs at least one example, reference, or doc file" if support_files.empty?

  unless agent_file.file?
    errors << "skills/#{folder} is missing agents/openai.yaml"
    next
  end

  agent_text = agent_file.read
  begin
    agent_metadata = YAML.safe_load(
      agent_text,
      permitted_classes: [],
      permitted_symbols: [],
      aliases: false
    )
  rescue Psych::Exception => error
    errors << "skills/#{folder}/agents/openai.yaml has invalid YAML: #{error.message.lines.first.strip}"
    agent_metadata = {}
  end
  interface = agent_metadata.is_a?(Hash) ? agent_metadata["interface"] : nil
  unless interface.is_a?(Hash)
    errors << "skills/#{folder}/agents/openai.yaml must contain an interface mapping"
    interface = {}
  end
  %w[display_name short_description default_prompt].each do |field|
    value = interface[field]
    errors << "skills/#{folder}/agents/openai.yaml is missing #{field}" unless value.is_a?(String) && !value.strip.empty?
  end
  default_prompt = interface["default_prompt"].to_s
  errors << "skills/#{folder}/agents/openai.yaml default_prompt must name $#{folder}" unless default_prompt.match?(/\$#{Regexp.escape(folder)}\b/)
end

%w[AGENTS.md CLAUDE.md CODEX.md README.md].each do |inventory|
  text = ROOT.join(inventory).read
  skill_roots.each do |skill_root|
    folder = skill_root.basename.to_s
    errors << "#{inventory} does not list #{folder}" unless text.include?(folder)
  end
end

json_paths = [
  ROOT.join(".codex-plugin", "plugin.json"),
  ROOT.join(".claude-plugin", "plugin.json"),
  ROOT.join(".claude-plugin", "marketplace.json")
]
parsed_json = {}
json_paths.each do |path|
  unless path.file?
    errors << "missing #{path.relative_path_from(ROOT)}"
    next
  end
  begin
    parsed_json[path] = JSON.parse(path.read)
  rescue JSON::ParserError => error
    errors << "#{path.relative_path_from(ROOT)} is invalid JSON: #{error.message}"
  end
end

codex_manifest = parsed_json[ROOT.join(".codex-plugin", "plugin.json")]
claude_manifest = parsed_json[ROOT.join(".claude-plugin", "plugin.json")]
if codex_manifest
  errors << ".codex-plugin/plugin.json must preserve name ios-swift-skills" unless codex_manifest["name"] == "ios-swift-skills"
  errors << ".codex-plugin/plugin.json must point skills to ./skills/" unless codex_manifest["skills"] == "./skills/"
  errors << ".codex-plugin/plugin.json version must be #{EXPECTED_PLUGIN_VERSION}" unless codex_manifest["version"] == EXPECTED_PLUGIN_VERSION
end
if claude_manifest
  errors << ".claude-plugin/plugin.json must preserve name ios-swift-skills" unless claude_manifest["name"] == "ios-swift-skills"
  errors << ".claude-plugin/plugin.json version must be #{EXPECTED_PLUGIN_VERSION}" unless claude_manifest["version"] == EXPECTED_PLUGIN_VERSION
end

marketplace = parsed_json[ROOT.join(".claude-plugin", "marketplace.json")]
if marketplace
  plugin_entry = marketplace.fetch("plugins", []).find { |entry| entry["name"] == "ios-swift-skills" }
  errors << ".claude-plugin/marketplace.json must preserve the ios-swift-skills entry" unless plugin_entry
  errors << ".claude-plugin/marketplace.json must keep ios-swift-skills source at ./" if plugin_entry && plugin_entry["source"] != "./"
end

markdown_paths = %w[README.md CONTRIBUTING.md AGENTS.md CLAUDE.md CODEX.md].map { |path| ROOT.join(path) } +
                 ROOT.glob("docs/*.md") +
                 skill_roots.flat_map { |root| root.glob("**/*.md") }
markdown_paths.uniq.each { |path| validate_markdown(path, errors) }

if errors.empty?
  puts "Validated #{skill_roots.length} skills, portable metadata, Markdown links, and plugin manifests."
  exit 0
end

warn "Skill validation failed with #{errors.length} issue#{errors.length == 1 ? '' : 's'}:"
errors.each { |error| warn "- #{error}" }
exit 1
