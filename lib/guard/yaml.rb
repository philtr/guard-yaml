require "guard/plugin"
require "guard/yaml/diagnostic"
require "guard/yaml/diagnostic_formatter"
require "guard/yaml/version"
require "yaml"

module Guard
  class Yaml < Plugin
    DEFAULT_ALL_PATHS = ["**/*.yaml", "**/*.yml"].freeze

    def run_all
      patterns = Array((options || {}).fetch(:all_paths, DEFAULT_ALL_PATHS))
      paths = patterns.flat_map { |pattern| Dir.glob(pattern) }.select { |path| File.file?(path) }.uniq.sort

      validate(paths)
    end

    def run_on_changes(paths)
      validate(paths)
    end

    private

    def validate(paths)
      failed = paths.reject { |path| valid_yaml?(path) }
      valid_count = paths.length - failed.length
      summary = "Checked #{paths.length} YAML #{pluralize(paths.length, "file")}: "         "#{valid_count} valid, #{failed.length} invalid."

      failed.empty? ? UI.info(summary) : UI.error(summary)
      throw :task_has_failed unless failed.empty?

      true
    end

    def valid_yaml?(path)
      File.open(path, "r:bom|utf-8") do |file|
        Psych.parse_stream(file, filename: path)
      rescue Psych::SyntaxError => error
        report_syntax_error(error, file, path)
        return false
      end

      true
    rescue SystemCallError => error
      UI.error("#{path}: #{error.message}")
      false
    end

    def report_syntax_error(error, file, path)
      diagnostic = YamlSupport::Diagnostic.from_syntax_error(
        error,
        path: path,
        source_line: source_line(file, error.line)
      )
      UI.error(YamlSupport::DiagnosticFormatter.new.format(diagnostic))
    end

    def pluralize(count, singular)
      (count == 1) ? singular : "#{singular}s"
    end

    def source_line(file, line_number)
      return unless line_number&.positive?

      file.rewind
      file.each_line.with_index(1).find { |_, index| index == line_number }&.first&.chomp
    rescue EncodingError, IOError, SystemCallError
      nil
    end
  end
end
