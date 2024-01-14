# RubyLsp::DryAutoInject

This is a spike into hooking up the [ruby-lsp](https://github.com/Shopify/ruby-lsp) gem with [dry-auto_inject](https://github.com/dry-rb/dry-auto_inject).

It's not released or published at this time.

## Toying around

Quick video showing how to toy around with this in VSCode...

https://github.com/zdennis/ruby-lsp-dry-auto_inject/assets/967/9bae03e6-dc63-46ca-aab0-b4a00f98505b

## Installation

Currently not published...

## Usage

TBD

## Development

After checking out the repo, run `bin/setup` to install dependencies.

Go into the `example_app/` directory and run:

```shell
bundle

# Run this to debug
bin/debug
```

### Playing around in VSCode

Open the `example_app/` directory in VSCode and:

- Open Output for Ruby LSP
- Start/Restart Ruby LSP Server to see output
- Open the `app.rb` file and then right-click on any constant or reference and choose _Go to definition_.
  -  this naively matches up dependencies found in `dependencies.rb` with their registered constant.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zdennis/ruby-lsp-dry-auto_inject.
