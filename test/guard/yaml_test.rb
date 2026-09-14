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

  def test_guardfile_template_watches_yml_and_yaml_files
    template = Guard::Yaml.template(Dir.pwd)

    assert_includes template, "ya?ml"
  end

  def test_valid_yaml_does_not_report_an_error
    with_yaml("---\nname: guard-yaml\n") do |path|
      result, messages = run_plugin([path])

      assert_equal :passed, result
      assert_equal ["Checked 1 YAML file: 1 valid, 0 invalid."], messages[:info]
      assert_empty messages[:error]
    end
  end

  def test_invalid_yaml_reports_a_syntax_error
    with_yaml("---\nitems: [one, two\n") do |path|
      result, messages = run_plugin([path])
      output = messages[:error].join("\n")

      assert_nil result
      assert_includes output, "#{path}:2:8: did not find expected ',' or ']'"
      assert_includes output, "context: while parsing a flow sequence"
      assert_includes output, "2 | items: [one, two"
      assert_includes output, "    |        ^"
      assert_includes output, "Checked 1 YAML file: 0 valid, 1 invalid."
    end
  end

  def test_invalid_later_document_in_stream_reports_a_syntax_error
    with_yaml("---\nname: valid\n---\nitems: [one, two\n") do |path|
      result, messages = run_plugin([path])
      output = messages[:error].join("\n")

      assert_nil result
      assert_includes output, "#{path}:4:8: did not find expected ',' or ']'"
    end
  end

  def test_reports_each_invalid_changed_file
    with_yaml("first: [broken\n") do |first_path|
      with_yaml("second: {broken\n") do |second_path|
        result, messages = run_plugin([first_path, second_path])
        output = messages[:error].join("\n")

        assert_nil result
        assert_includes output, first_path
        assert_includes output, second_path
        assert_equal 2, output.scan("did not find expected").length
        assert_includes output, "Checked 2 YAML files: 0 valid, 2 invalid."
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
        result, messages = run_plugin([path])
        output = messages[:error].join("\n")

        assert_nil result, description
        assert_includes output, path, description
        assert_includes output, yaml.lines.last.chomp, description
        assert_includes output, "^", description
      end
    end
  end

  def test_valid_multi_document_stream_does_not_report_an_error
    with_yaml("---\nname: first\n---\nname: second\n") do |path|
      result, messages = run_plugin([path])

      assert_equal :passed, result
      assert_empty messages[:error]
    end
  end

  def test_valid_ruby_object_tag_is_parsed_without_deserialization
    with_yaml("--- !ruby/object:Object {}\n") do |path|
      result, messages = run_plugin([path])

      assert_equal :passed, result
      assert_empty messages[:error]
    end
  end

  def test_missing_changed_file_reports_failure_without_raising
    path = "/missing/guard-yaml.yml"

    result, messages = run_plugin([path])

    assert_nil result
    assert_includes messages[:error].first, path
    assert_equal "Checked 1 YAML file: 0 valid, 1 invalid.", messages[:error].last
  end

  def test_run_all_validates_configured_yaml_globs
    Dir.mktmpdir("guard-yaml") do |directory|
      File.write(File.join(directory, "valid.yml"), "name: valid\n")
      File.write(File.join(directory, "invalid.yaml"), "items: [broken\n")
      File.write(File.join(directory, "ignored.txt"), "items: [broken\n")
      @plugin.options = {all_paths: [File.join(directory, "*.yml"), File.join(directory, "*.yaml")]}

      result, messages = run_plugin { @plugin.run_all }

      assert_nil result
      assert_includes messages[:error].join("\n"), "invalid.yaml"
      refute_includes messages[:error].join("\n"), "ignored.txt"
      assert_equal "Checked 2 YAML files: 1 valid, 1 invalid.", messages[:error].last
    end
  end

  def test_strict_alias_policy_reports_alias_references_as_errors
    @plugin.options = {strict: {aliases: false}}

    with_yaml("default: &default value\ncopy: *default\n") do |path|
      result, messages = run_plugin([path])
      output = messages[:error].join("\n")

      assert_nil result
      assert_includes output, "#{path}:2:7: alias references are not allowed"
      assert_includes output, "2 | copy: *default"
      assert_equal "Checked 1 YAML file: 0 valid, 1 invalid.", messages[:error].last
    end
  end

  def test_strict_tag_policy_reports_explicit_tags_as_errors
    @plugin.options = {strict: {tags: false}}

    with_yaml("value: !application/value accepted\n") do |path|
      result, messages = run_plugin([path])

      assert_nil result
      assert_includes messages[:error].join("\n"), "explicit tags are not allowed"
    end
  end

  def test_unknown_strict_options_fail_before_validation
    @plugin.options = {strict: {styles: false}}

    error = assert_raises(ArgumentError) do
      run_plugin([])
    end

    assert_equal "unknown strict option: :styles", error.message
  end

  private

  def run_plugin(paths = nil, &block)
    messages = {error: [], info: []}
    invocation = block || -> { @plugin.run_on_changes(paths) }
    result = nil

    Guard::UI.stub(:error, ->(message) { messages[:error] << message }) do
      Guard::UI.stub(:info, ->(message) { messages[:info] << message }) do
        result = catch(:task_has_failed) do
          invocation.call
          :passed
        end
      end
    end

    [result, messages]
  end

  def with_yaml(contents)
    Tempfile.create(["guard-yaml", ".yml"]) do |file|
      file.write(contents)
      file.flush
      yield file.path
    end
  end
end
