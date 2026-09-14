# frozen_string_literal: true

module Guard
  module YamlSupport
    class Diagnostic
      attr_reader :column, :context, :line, :path, :problem, :source_line

      def self.from_syntax_error(error, path:, source_line: nil)
        new(
          path: path,
          line: error.line,
          column: error.column,
          problem: error.problem,
          context: error.context,
          source_line: source_line
        )
      end

      def initialize(path:, line:, column:, problem:, context:, source_line:)
        @path = path
        @line = line
        @column = column
        @problem = problem
        @context = context
        @source_line = source_line
      end
    end
  end
end
