# frozen_string_literal: true

require "minitest/autorun"
require "tempfile"

ENV["GUARD_STRICT"] = "1"

require "guard/yaml"

class GuardYamlConstructsTest < Minitest::Test
  VALID_DOCUMENTS = {
    "aliases and anchors" => <<~YAML,
      defaults: &defaults
        adapter: postgresql
      development:
        <<: *defaults
        database: app_development
    YAML
    "block scalars" => <<~YAML,
      literal: |
        first line
        second line
      folded: >
        one folded
        paragraph
    YAML
    "comments and document markers" => <<~YAML,
      %YAML 1.1
      ---
      # Configuration comment
      enabled: true
      ...
    YAML
    "empty document stream" => "---\n---\n...\n",
    "explicit tags" => <<~YAML,
      timestamp: !!timestamp 2026-09-13
      custom: !application/value accepted
    YAML
    "multi-document stream" => <<~YAML,
      ---
      name: first
      ---
      name: second
    YAML
    "nested mappings and sequences" => <<~YAML,
      application:
        environments:
          - name: development
            features:
              diagnostics: true
          - name: production
            features: {}
    YAML
    "quoted and unquoted scalars" => <<~YAML,
      plain: ordinary value
      single: 'it''s YAML'
      double: "line one\nline two"
    YAML
    "unicode content" => <<~YAML,
      greeting: "Howdy, 世界 🤠"
      café: résumé
    YAML
    "unusual valid whitespace" => <<~YAML
      sequence:
      - one
      - two

      mapping: {one: 1, two: 2}
    YAML
  }.freeze

  INVALID_DOCUMENTS = {
    "flow mapping" => "root: {key: value\n",
    "flow sequence" => "items: [one, two\n",
    "indentation" => "root:\n  child: one\n   sibling: two\n",
    "quoted scalar" => "name: \"unterminated\n"
  }.freeze

  def setup
    @plugin = Guard::Yaml.allocate
  end

  def test_accepts_representative_valid_yaml_constructs
    VALID_DOCUMENTS.each do |description, yaml|
      assert_valid_yaml(yaml, description)
    end
  end

  def test_accepts_an_empty_file
    assert_valid_yaml("", "empty file")
  end

  def test_rejects_representative_invalid_yaml_constructs
    INVALID_DOCUMENTS.each do |description, yaml|
      with_yaml(yaml) do |path|
        stdout, stderr = capture_io { @plugin.run_on_changes([path]) }

        assert_includes stdout, path, description
        assert_includes stdout, "^", description
        assert_empty stderr, description
      end
    end
  end

  private

  def assert_valid_yaml(yaml, description)
    with_yaml(yaml) do |path|
      stdout, stderr = capture_io { @plugin.run_on_changes([path]) }

      assert_empty stdout, description
      assert_empty stderr, description
    end
  end

  def with_yaml(contents)
    Tempfile.create(["guard-yaml", ".yml"]) do |file|
      file.write(contents)
      file.flush
      yield file.path
    end
  end
end
