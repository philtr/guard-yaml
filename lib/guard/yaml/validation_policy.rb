# frozen_string_literal: true

require "psych"

module Guard
  module YamlSupport
    class ValidationPolicy
      DEFAULTS = {aliases: true, tags: true}.freeze
      SUPPORTED_OPTIONS = DEFAULTS.keys.freeze

      class Violation
        attr_reader :column, :line, :problem

        def initialize(column:, line:, problem:)
          @column = column
          @line = line
          @problem = problem
        end
      end

      def initialize(options = {})
        validate_options!(options)
        @options = DEFAULTS.merge(options)
      end

      def violations(stream)
        each_node(stream).filter_map do |node|
          violation_for(node)
        end
      end

      private

      def each_node(node, &block)
        return enum_for(__method__, node) unless block

        yield node
        Array(node.respond_to?(:children) ? node.children : nil).each do |child|
          each_node(child, &block)
        end
      end

      def violation_for(node)
        if !@options[:aliases] && node.is_a?(Psych::Nodes::Alias)
          violation(node, "alias references are not allowed (found *#{node.anchor})")
        elsif !@options[:tags] && node.respond_to?(:tag) && node.tag
          violation(node, "explicit tags are not allowed (found #{node.tag})")
        end
      end

      def violation(node, problem)
        Violation.new(
          line: node.start_line + 1,
          column: node.start_column + 1,
          problem: problem
        )
      end

      def validate_options!(options)
        unless options.is_a?(Hash)
          raise ArgumentError, "strict must be a hash"
        end

        unknown = options.keys - SUPPORTED_OPTIONS
        unless unknown.empty?
          raise ArgumentError, "unknown strict option: #{unknown.map(&:inspect).join(", ")}"
        end

        invalid = options.find { |_, value| ![true, false].include?(value) }
        if invalid
          raise ArgumentError, "strict option #{invalid.first.inspect} must be true or false"
        end
      end
    end
  end
end
