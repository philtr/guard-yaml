require "guard/plugin"
require "guard/yaml/version"
require "yaml"

module Guard
  class Yaml < Plugin
    def run_on_changes(paths)
      paths.each do |path|
        File.open(path, "r:bom|utf-8") do |file|
          Psych.parse_stream(file, filename: path)
        end
      rescue Psych::SyntaxError => e
        puts "#{e.class}: #{e.message}"
      end
    end
  end
end
