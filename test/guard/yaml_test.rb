# frozen_string_literal: true

require "minitest/autorun"
require "tempfile"

ENV["GUARD_STRICT"] = "1"

require "guard/yaml"

class GuardYamlTest < Minitest::Test
  def setup
    @plugin = Guard::Yaml.allocate
  end

  def test_exposes_a_version
    refute_empty Guard::YamlVersion::VERSION
  end

  def test_is_a_guard_plugin
    assert_operator Guard::Yaml, :<, Guard::Plugin
  end

  def test_valid_yaml_does_not_report_an_error
    with_yaml("---\nname: guard-yaml\n") do |path|
      stdout, stderr = capture_io { @plugin.run_on_changes([path]) }

      assert_empty stdout
      assert_empty stderr
    end
  end

  def test_invalid_yaml_reports_a_syntax_error
    with_yaml("---\nitems: [one, two\n") do |path|
      stdout, stderr = capture_io { @plugin.run_on_changes([path]) }

      assert_match(/Psych::SyntaxError/, stdout)
      assert_includes stdout, path
      assert_empty stderr
    end
  end

  def test_invalid_later_document_in_stream_reports_a_syntax_error
    with_yaml("---\nname: valid\n---\nitems: [one, two\n") do |path|
      stdout, stderr = capture_io { @plugin.run_on_changes([path]) }

      assert_match(/Psych::SyntaxError/, stdout)
      assert_includes stdout, path
      assert_empty stderr
    end
  end

  def test_valid_multi_document_stream_does_not_report_an_error
    with_yaml("---\nname: first\n---\nname: second\n") do |path|
      stdout, stderr = capture_io { @plugin.run_on_changes([path]) }

      assert_empty stdout
      assert_empty stderr
    end
  end

  def test_valid_ruby_object_tag_is_parsed_without_deserialization
    with_yaml("--- !ruby/object:Object {}\n") do |path|
      stdout, stderr = capture_io { @plugin.run_on_changes([path]) }

      assert_empty stdout
      assert_empty stderr
    end
  end

  private

  def with_yaml(contents)
    Tempfile.create(["guard-yaml", ".yml"]) do |file|
      file.write(contents)
      file.flush
      yield file.path
    end
  end
end
