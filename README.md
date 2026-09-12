# Guard::Yaml

Checks your YAML syntax. That's all.

## Requirements

* [Guard](https://github.com/guard/guard) >= 2.18 and < 3

## Installation

Add this line to your application's Gemfile:

    gem 'guard-yaml'

And then execute:

    $ bundle install
    $ guard init guard-yaml

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Run the test suite with:

    bundle exec rake

## Releasing

Releases are published to RubyGems.org by GitHub Actions when a version tag is
pushed and CI passes. The tag must match the version in
`lib/guard/yaml/version.rb`, including the `v` prefix. For example, version
`0.1.0` must be tagged as `v0.1.0`.

Before the first automated release:

1. Create a GitHub environment named `release`.
2. Configure `philtr/guard-yaml` on RubyGems.org with a trusted publisher for
   workflow `ci.yml` and environment `release`.

No RubyGems API key is required. See the
[RubyGems trusted publishing guide](https://guides.rubygems.org/trusted-publishing/)
for setup details.
