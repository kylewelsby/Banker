# Banker 
[![Gem Version](https://badge.fury.io/rb/banker.png)][gem_version]
[![CI Build Status](https://secure.travis-ci.org/kylewelsby/Banker.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/kylewelsby/Banker.png?travis)][gemnasium]
[![Code Climate](https://codeclimate.com/github/kylewelsby/Banker.png)][code_climate]

[gem_version]:http://badge.fury.io/rb/banker
[travis]:http://travis-ci.org/kylewelsby/Banker
[gemnasium]:https://gemnasium.com/kylewelsby/Banker
[code_climate]:https://codeclimate.com/github/kylewelsby/Banker

A collection of strategies to access online bank accounts to obtain balance 
and transaction details.

## Supported Institutes

* Barclay's Bank => Barclays
* Barclaycard UK => BarclaycardUK
* Capital One UK => CapitalOneUK
* Lloyds TSB UK => LloydsTSBUK

####Extras

* Credit Expert UK => CreidtExpertUK

## Installation

Add this line to your application's Gemfile:

    gem 'banker'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install banker

## Example Usage



	user_params = {
		surname: "Bloggs",
		username: "Bloggs123",
		password: "password",
		memorable_word: "superduper",
		card_number: 4111111111111111,
		date_of_birth: Date.parse('2012-01-01')
	}

Get the balance in pennies of the account.

    # Barclays Bank
    Banker::Barclays.new(user_params).accounts.first
    # => <Banker::Account @name="Barclays Bank", @uid="cdd5f8e1c6e441fd9aac2786ca38c835", @amount=130000, @limit=-150000, @currency="GBP">


Extra strategies

    # Credit Expert UK
    Banker::CreditExpertUK.new(user_params).score #=> 800


## Dependancies

* Mechanize
* OFX

## Alternate Languages

* Python [Bank Scraper](https://github.com/MoneyToolkit/Bank-Scraper) from MoneyToolKit

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

This library is distributed under the MIT license.  Please see the [LICENSE](https://github.com/BritRuby/Banker/LICENSE.md) file.
