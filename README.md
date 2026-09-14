# Guard::Yaml

`guard-yaml` provides immediate YAML parsing and validity feedback through
[Guard](https://github.com/guard/guard). It checks changed YAML files, shows
source-focused syntax diagnostics, and can validate every configured YAML file
on demand.

## Requirements

- Ruby 3.1 or newer
- Guard 2.18 or newer and earlier than Guard 3

## Installation

Add the gem to your application's `Gemfile`:

```ruby
gem "guard-yaml"
```

Install the bundle and generate the Guardfile entry:

```sh
bundle install
bundle exec guard init yaml
```

## Guardfile configuration

The generated configuration watches YAML files under `config/` with either a
`.yml` or `.yaml` extension:

```ruby
guard :yaml do
  watch(%r{^config/.*\.ya?ml$})
end
```

Guard passes matching changed files directly to the plugin. Press Enter in an
interactive Guard session to run validation for all YAML files. By default,
`run_all` searches the project with `**/*.yml` and `**/*.yaml`.

Use `all_paths` when the full-project scan should cover different locations:

```ruby
guard :yaml, all_paths: ["config/**/*.yml", "config/**/*.yaml"] do
  watch(%r{^config/.*\.ya?ml$})
end
```

The watcher and `all_paths` serve different Guard lifecycle events: watchers
select changed files, while `all_paths` supplies filesystem globs for
`run_all`. Guard watcher regular expressions cannot be converted reliably into
filesystem globs.

## Output and failure behavior

A successful run reports one concise summary:

```text
Checked 2 YAML files: 2 valid, 0 invalid.
```

Invalid YAML reports the parser problem, location, source context, and a caret
when those details are available:

```text
config/settings.yml:2:8: did not find expected ',' or ']'
  context: while parsing a flow sequence
  2 | items: [one, two
    |        ^
Checked 2 YAML files: 1 valid, 1 invalid.
```

Every supplied file is checked, so one run can report failures from multiple
files. Invalid or unreadable files signal Guard's `:task_has_failed` result
after all diagnostics have been emitted. This supports Guard group failure
handling without terminating the interactive session.

## Optional validation policy

Valid YAML can contain constructs that some projects choose not to accept.
Configure those parser-level decisions with `strict`:

```ruby
guard :yaml, strict: {aliases: false, tags: false} do
  watch(%r{^config/.*\.ya?ml$})
end
```

Both options default to `true`, preserving ordinary YAML compatibility:

| Option | Default | When set to `false` |
| --- | --- | --- |
| `aliases` | `true` | Rejects alias references such as `*defaults`. Anchor declarations remain valid. |
| `tags` | `true` | Rejects explicit core and custom tags such as `!!str` and `!application/value`. |

Policy violations use the same source-focused diagnostics and Guard failure
signal as syntax errors. Unknown options, non-boolean option values, and a
non-hash `strict` value raise `ArgumentError` rather than being ignored.

Duplicate-key policy is not currently supported. Correct duplicate-key
handling requires YAML key-equivalence and merge semantics beyond Psych's
direct syntax metadata.

## Project boundary

`guard-yaml` intentionally provides YAML parsing, narrowly scoped validity
policy, and immediate Guard feedback. It does not enforce formatting, key
ordering or grouping, broader YAML style preferences, or schema contracts.
Use a dedicated linter for style and a schema validator for data contracts.

## Development

Install dependencies and run the test suite:

```sh
bundle install
bundle exec rake
```

Run StandardRB and verify gem packaging:

```sh
bundle exec standardrb
bundle exec rake build
```

The test suite uses Minitest and exercises the supported Ruby/Guard contract,
syntax diagnostics, common YAML constructs, Guard lifecycle behavior, and
validation policy.

## Contributing

1. Fork the repository.
2. Create a focused branch.
3. Add or update Minitest coverage for behavioral changes.
4. Run the development checks above.
5. Open a focused pull request against `master`.

## Releasing

After CI passes on `master`, GitHub Actions checks the version in
`lib/guard/yaml/version.rb`. If its version tag does not exist, the workflow
creates the tag and publishes the gem to RubyGems.org.

No RubyGems API key is required. See the
[RubyGems trusted publishing guide](https://guides.rubygems.org/trusted-publishing/)
for setup details.

## Maintainers

Originally created by [Phillip Ridlen](https://github.com/philtr).

Currently maintained by Phillip Ridlen and [Stan Carver II](https://github.com/scarver2).

## License

The gem is available under the terms of the [MIT License](LICENSE.txt).
