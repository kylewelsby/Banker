# Banker [![CI Build Status](https://secure.travis-ci.org/BritRuby/Banker.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/BritRuby/Banker.png?travis)][gemnasium]

[travis]:http://travis-ci.org/BritRuby/Banker
[gemnasium]:https://gemnasium.com/BritRuby/Banker

## Supported Institutes

* Barclay's Bank => Barclays
* Barclaycard UK => BarclaycardUK
* Capital One UK => CapitalOneUK
* Lloyds TSB UK => LloydsTSBUK

####Extras

* Credit Expert UK => CreidtExpertUK

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

## License

This library is distributed under the MIT license.  Please see the [LICENSE](https://github.com/BritRuby/Banker/LICENSE.md) file.
