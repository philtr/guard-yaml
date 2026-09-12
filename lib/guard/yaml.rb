require "guard/plugin"
require "guard/yaml/version"
require "yaml"

module Guard
  class Yaml < Plugin
    def run_on_changes(paths)
      paths.each do |path|
        YAML.load(File.open(path))
      rescue Psych::SyntaxError => e
        puts "#{e.class}: #{e.message}"
      end
    end
  end
end
