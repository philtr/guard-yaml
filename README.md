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

After CI passes on `master`, GitHub Actions checks the version in
`lib/guard/yaml/version.rb`. If its version tag does not exist, the workflow
creates the tag and publishes the gem to RubyGems.org.

Before the first automated release:

1. Create a GitHub environment named `release`.
2. Configure `philtr/guard-yaml` on RubyGems.org with a trusted publisher for
   workflow `ci.yml` and environment `release`.

No RubyGems API key is required. See the
[RubyGems trusted publishing guide](https://guides.rubygems.org/trusted-publishing/)
for setup details.
