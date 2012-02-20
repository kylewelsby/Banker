# Banker [![CI Build Status](https://secure.travis-ci.org/BritRuby/Banker.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/BritRuby/Banker.png?travis)][gemnasium]

[travis]:http://travis-ci.org/BritRuby/Banker
[gemnasium]:https://gemnasium.com/BritRuby/Banker

## Supported Institutes

* Barclay's Bank
* Barclaycard UK
* Capital One UK
* Lloyds TSB UK

Extras
* Credit Expert UK

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
	Banker::Stratagies::Barclays.new(user_params).balance #=> 410000

    # Barclaycard UK
    Banker::Strategies::BarclaycardUK.new(user_params).balance #=> 12300

    # Lloyds TSB UK
    Banker::Stratagies::LloydsTSBUK.new(user_params).balance #=> 22049

    # Capital One UK
    Banker::Stratagies::CapitalOneUK.new(user_params).balance #=> 42000

Extra strategies

    # Credit Expert UK
    Banker::Stratagies::CreditExpertUK.new(user_params).score #=> 800


## Alternate Languages

* Python [Bank Scraper](https://github.com/MoneyToolkit/Bank-Scraper) from MoneyToolKit

## License

This library is distributed under the MIT license.  Please see the [LICENSE](https://github.com/BritRuby/Banker/LICENSE.md) file.
