# Banker [![CI Build Status](https://secure.travis-ci.org/kylewelsby/Banker.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/kylewelsby/Banker.png?travis)][gemnasium]

[travis]:http://travis-ci.org/kylewelsby/Banker
[gemnasium]:https://gemnasium.com/kylewelsby/Banker

## Supported Institutes

* Barclay's Bank
* Capital One UK

## Getting Started

Initiate a bank instance.

    barclays = Banker::Stratagies::Barclays.new(surname: "Bloggs",
                         			card_number: 4111111111111111,
                         			date_of_birth: Date.parse('2012-01-01'),
                         			memorable_word: "superduper"
    )

    capital_one = Banker::Stratagies::CapitalOneUK.new(username: "Bloggs",
                         			password: "password"
    )


Get the balance of the account.

    barclays.balance #=>410000

    capital_one.balance #=> 0

## Alternate Languages

* Python [Bank Scraper](https://github.com/MoneyToolkit/Bank-Scraper) from MoneyToolKit

## License

This library is distributed under the MIT license.  Please see the [LICENSE](https://github.com/kylewelsby/Banker/LICENSE.md) file.
