# Banker [![CI Build Status](https://secure.travis-ci.org/kylewelsby/Banker.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/kylewelsby/Banker.png?travis)][gemnasium]

[travis]:http://travis-ci.org/kylewelsby/Banker
[gemnasium]:https://gemnasium.com/kylewelsby/Banker

## Supported Institutes

* Barclay's Bank
* Lloyds TSB UK
* Capital One UK

## Example Usage

	user_params = {
		surname: "Bloggs",
		username: "Bloggs123",
		password: "password",
		memorable_word: "superduper",
		card_number: 4111111111111111,
		date_of_birth: Date.parse('2012-01-01')
	}

    # Barclays Bank
	Banker::Stratagies::Barclays.new(user_params).balance #=> 410000

	# Lloyds TSB UK
    Banker::Stratagies::LloydsTSBUK.new(user_params).balance #=> 22049

	# Capital One UK
    Banker::Stratagies::CapitalOneUK.new(user_params).balance #=> 0

## Alternate Languages

* Python [Bank Scraper](https://github.com/MoneyToolkit/Bank-Scraper) from MoneyToolKit

## License

This library is distributed under the MIT license.  Please see the [LICENSE](https://github.com/kylewelsby/Banker/LICENSE.md) file.
