# frozen_string_literal: true

require "minitest/autorun"
require "psych"

require "guard/yaml/validation_policy"

class ValidationPolicyTest < Minitest::Test
  def test_defaults_allow_aliases_and_explicit_tags
    stream = parse(<<~YAML)
      default: &default value
      copy: *default
      tagged: !application/value accepted
    YAML

    assert_empty Guard::YamlSupport::ValidationPolicy.new.violations(stream)
  end

  def test_alias_policy_rejects_alias_references_but_not_anchor_declarations
    stream = parse(<<~YAML)
      default: &default value
      copy: *default
    YAML

    violations = policy(aliases: false).violations(stream)

    assert_equal 1, violations.length
    assert_equal 2, violations.first.line
    assert_equal 7, violations.first.column
    assert_equal "alias references are not allowed (found *default)", violations.first.problem
  end

  def test_tag_policy_rejects_core_and_custom_explicit_tags
    stream = parse(<<~YAML)
      core: !!str value
      custom: !application/value accepted
    YAML

    violations = policy(tags: false).violations(stream)

    assert_equal 2, violations.length
    assert_equal ["tag:yaml.org,2002:str", "!application/value"],
      violations.map { |violation| violation.problem[/found (.+)\)/, 1] }
  end

  def test_unknown_options_fail_clearly
    error = assert_raises(ArgumentError) do
      policy(duplicate_keys: false)
    end

    assert_equal "unknown strict option: :duplicate_keys", error.message
  end

  def test_option_values_must_be_boolean
    error = assert_raises(ArgumentError) do
      policy(aliases: :warn)
    end

    assert_equal "strict option :aliases must be true or false", error.message
  end

  def test_strict_configuration_must_be_a_hash
    error = assert_raises(ArgumentError) do
      Guard::YamlSupport::ValidationPolicy.new(true)
    end

    assert_equal "strict must be a hash", error.message
  end

  private

  def parse(yaml)
    Psych.parse_stream(yaml)
  end

  def policy(**options)
    Guard::YamlSupport::ValidationPolicy.new(options)
  end
end
