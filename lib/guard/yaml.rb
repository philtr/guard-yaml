require "guard/plugin"
require "guard/yaml/diagnostic"
require "guard/yaml/diagnostic_formatter"
require "guard/yaml/version"
require "yaml"

module Guard
  class Yaml < Plugin
    def run_on_changes(paths)
      paths.each do |path|
        File.open(path, "r:bom|utf-8") do |file|
          Psych.parse_stream(file, filename: path)
        rescue Psych::SyntaxError => error
          diagnostic = YamlSupport::Diagnostic.from_syntax_error(
            error,
            path: path,
            source_line: source_line(file, error.line)
          )
          puts YamlSupport::DiagnosticFormatter.new.format(diagnostic)
        end
      end
    end

    private

    def source_line(file, line_number)
      return unless line_number&.positive?

      file.rewind
      file.each_line.with_index(1).find { |_, index| index == line_number }&.first&.chomp
    rescue EncodingError, IOError, SystemCallError
      nil
    end
  end
end
