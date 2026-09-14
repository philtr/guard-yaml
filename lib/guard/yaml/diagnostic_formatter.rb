# frozen_string_literal: true

module Guard
  module YamlSupport
    class DiagnosticFormatter
      TAB_WIDTH = 2

      def format(diagnostic)
        lines = [header(diagnostic)]
        lines << "  context: #{diagnostic.context}" if present?(diagnostic.context)
        lines.concat(source_excerpt(diagnostic)) if diagnostic.source_line
        lines.join("\n")
      end

      private

      def header(diagnostic)
        location = [diagnostic.path, diagnostic.line, diagnostic.column].compact.join(":")
        present?(diagnostic.problem) ? "#{location}: #{diagnostic.problem}" : location
      end

      def present?(value)
        value && !value.empty?
      end

      def source_excerpt(diagnostic)
        line_number = diagnostic.line || "?"
        gutter = line_number.to_s.length
        source_line = expand_tabs(diagnostic.source_line)
        caret = caret_padding(diagnostic.source_line, diagnostic.column)

        [
          "  #{line_number} | #{source_line}",
          "  #{" " * gutter} | #{caret}^"
        ]
      end

      def caret_padding(source_line, column)
        return "" unless column&.positive?

        characters = source_line.each_char.take(column - 1).join
        expand_tabs(characters).each_char.map { " " }.join
      end

      def expand_tabs(text)
        column = 0

        text.each_char.with_object(+"") do |character, expanded|
          width = (character == "\t") ? TAB_WIDTH - (column % TAB_WIDTH) : 1
          expanded << ((character == "\t") ? " " * width : character)
          column += width
        end
      end
    end
  end
end
