# Pact::Xml

Provides XML support for the Pact gem.

## Installation

Add this line to your application's Gemfile:

    gem 'pact-xml'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pact-xml

## Usage

```ruby
require 'pact'
require 'pact/xml'

Pact.configure do | config |
    
    config.register_body_differ /xml/, Pact::XML::Differ
    config.diff_formatter = Pact::XML::DiffFormatter

end

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pact-xml/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
