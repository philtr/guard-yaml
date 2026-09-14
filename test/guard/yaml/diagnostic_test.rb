# frozen_string_literal: true

require "minitest/autorun"

require "guard/yaml/diagnostic"

class DiagnosticTest < Minitest::Test
  def test_extracts_structured_data_from_a_syntax_error
    error = syntax_error_for("items: [one, two\n", "broken.yml")

    diagnostic = Guard::YamlSupport::Diagnostic.from_syntax_error(
      error,
      path: "broken.yml",
      source_line: "items: [one, two"
    )

    assert_equal "broken.yml", diagnostic.path
    assert_equal 1, diagnostic.line
    assert_equal 8, diagnostic.column
    assert_equal "did not find expected ',' or ']'", diagnostic.problem
    assert_equal "while parsing a flow sequence", diagnostic.context
    assert_equal "items: [one, two", diagnostic.source_line
  end

  private

  def syntax_error_for(yaml, path)
    Psych.parse_stream(yaml, filename: path)
  rescue Psych::SyntaxError => error
    error
  end
end
