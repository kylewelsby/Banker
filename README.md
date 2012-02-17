# Banker

## Getting Started

Configure the application with the bank or credit stratagy you wish to use.

    Banker::Builder do
      bank :barclays
    end

Initiate a bank instance.

    barclays = Banker::Barclays.new(surname: "Bloggs",
                         			card_number: 4111111111111111,
                         			date_of_birth: Date.parse('2012-01-01'),
                         			memorable_word: "superduper"
    )

Get the balance of the account.

    barclays.get_balance #=> <Money cents: 400000, currency: "GBP">


