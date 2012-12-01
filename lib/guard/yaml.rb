require 'guard'
require 'guard/guard'
require "guard/yaml/version"

module Guard
  class Yaml < Guard
    def run_on_changes(paths)
      paths.each do |path|
        begin
          YAML.load(File.open(path))
        rescue Psych::SyntaxError => e
          puts "#{e.class}: #{e.message}"
        end
      end
    end
  end
end
