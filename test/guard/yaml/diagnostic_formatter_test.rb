# frozen_string_literal: true

require "minitest/autorun"

require "guard/yaml/diagnostic"
require "guard/yaml/diagnostic_formatter"

class DiagnosticFormatterTest < Minitest::Test
  def test_formats_structured_diagnostic_with_source_context
    diagnostic = diagnostic_for(
      path: "config/example.yml",
      line: 3,
      column: 10,
      problem: "did not find expected ',' or ']'",
      context: "while parsing a flow sequence",
      source_line: "items: [one, two"
    )

    output = Guard::YamlSupport::DiagnosticFormatter.new.format(diagnostic)

    assert_equal <<~OUTPUT.chomp, output
      config/example.yml:3:10: did not find expected ',' or ']'
        context: while parsing a flow sequence
        3 | items: [one, two
          |          ^
    OUTPUT
  end

  def test_omits_unavailable_parser_and_source_context
    diagnostic = diagnostic_for(
      path: "missing.yml",
      line: nil,
      column: nil,
      problem: "syntax error",
      context: nil,
      source_line: nil
    )

    output = Guard::YamlSupport::DiagnosticFormatter.new.format(diagnostic)

    assert_equal "missing.yml: syntax error", output
  end

  def test_expands_tabs_when_positioning_the_caret
    diagnostic = diagnostic_for(
      path: "tabs.yml",
      line: 2,
      column: 3,
      problem: "syntax error",
      context: nil,
      source_line: "\tvalue"
    )

    output = Guard::YamlSupport::DiagnosticFormatter.new.format(diagnostic)

    assert_includes output, "  2 |   value"
    assert_includes output, "    |    ^"
  end

  def test_counts_unicode_as_characters_when_positioning_the_caret
    diagnostic = diagnostic_for(
      path: "unicode.yml",
      line: 1,
      column: 4,
      problem: "syntax error",
      context: nil,
      source_line: "π: ["
    )

    output = Guard::YamlSupport::DiagnosticFormatter.new.format(diagnostic)

    assert_includes output, "  1 | π: ["
    assert_includes output, "    |    ^"
  end

  private

  def diagnostic_for(**attributes)
    Guard::YamlSupport::Diagnostic.new(**attributes)
  end
end
