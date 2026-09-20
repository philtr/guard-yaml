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

      assert_includes stdout, "#{path}:2:8: did not find expected ',' or ']'"
      assert_includes stdout, "context: while parsing a flow sequence"
      assert_includes stdout, "2 | items: [one, two"
      assert_includes stdout, "    |        ^"
      assert_empty stderr
    end
  end

  def test_invalid_later_document_in_stream_reports_a_syntax_error
    with_yaml("---\nname: valid\n---\nitems: [one, two\n") do |path|
      stdout, stderr = capture_io { @plugin.run_on_changes([path]) }

      assert_includes stdout, "#{path}:4:8: did not find expected ',' or ']'"
      assert_empty stderr
    end
  end

  def test_reports_each_invalid_changed_file
    with_yaml("first: [broken\n") do |first_path|
      with_yaml("second: {broken\n") do |second_path|
        stdout, stderr = capture_io { @plugin.run_on_changes([first_path, second_path]) }

        assert_includes stdout, first_path
        assert_includes stdout, second_path
        assert_equal 2, stdout.scan("did not find expected").length
        assert_empty stderr
      end
    end
  end

  def test_reports_source_context_for_representative_syntax_failures
    malformed_documents = {
      "flow mapping" => "root: {key: value\n",
      "indentation" => "root:\n  child: one\n   sibling: two\n",
      "quoted scalar" => "name: \"unterminated\n"
    }

    malformed_documents.each do |description, yaml|
      with_yaml(yaml) do |path|
        stdout, stderr = capture_io { @plugin.run_on_changes([path]) }

        assert_includes stdout, path, description
        assert_includes stdout, yaml.lines.last.chomp, description
        assert_includes stdout, "^", description
        assert_empty stderr, description
      end
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
