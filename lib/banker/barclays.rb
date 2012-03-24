module Banker
  # This class allows the data retrieval of account data
  # for Barclay's Bank
  #
  # == Examples
  #
  # Get OFX from Barclay's
  #
  #     bank = Banker::Barclays.new(:surname => 'Bloggs',
  #     :date_of_birth => Date.parse('2012-01-01'),
  #     :memorable_word => 'superduper',
  #     :card_number => 4111111111111111)
  #
  #     data.balance #=> 410010
  #
  class Barclays
    attr_accessor :surname, :date_of_birth, :memorable_word,
      :card_number, :agent, :ofx, :balance
    LOGIN_ENDPOINT = 'https://ibank.barclays.co.uk/olb/y/BasicAccessStart.do'
    EXPORT_ENDPOINT = 'https://ibank.barclays.co.uk/olb/y/Redirect.do?go=ExportData1.do%3Faction%3DExport%2BBank%2BStatement%7C%7CExport%2BData&Go=Go'

    def initialize(args)
      @surname = args[:surname]
      @date_of_birth = args[:date_of_birth]
      @memorable_word = args[:memorable_word]
      @card_number = args[:card_number]

      @agent = Mechanize.new
      @agent.log = Logger.new "mech.log"
      @agent.user_agent = 'Mozilla/5.0 (Banker)'

      authenticate

      get_data

      @balance = @ofx.account.balance.amount_in_pennies
    end

    private

    def get_data
      page = @agent.get EXPORT_ENDPOINT

      form = page.forms_with(:action => "ExportData1.do")[0]

      form.FProductIdentifier = "All"
      form.FFormat = "6"

      page = @agent.submit(form, form.buttons.first)

      form = page.forms[1]

      file = @agent.submit(form, form.buttons.first)

      @ofx = OFX(file.body)

    end


    def authenticate
      page = @agent.get(LOGIN_ENDPOINT)
      form = page.forms.last

      form.surname = @surname

      form.connectCard1 = card_number_set(0)
      form.connectCard2 = card_number_set(1)
      form.connectCard3 = card_number_set(2)
      form.connectCard4 = card_number_set(3)

      page = @agent.submit(form, form.buttons.last)

      form = page.forms.first

      form.dobDay = @date_of_birth.day
      form.dobMonth = "0#{@date_of_birth.month}"
      form.dobYear = @date_of_birth.year

      first_letter = page.at("//select[@name='firstMDC']").attributes['title'].to_s.scan(/\d+/).first.to_i
      second_letter = page.at("//select[@name='secondMDC']").attributes['title'].to_s.scan(/\d+/).first.to_i

      form.firstMDC = get_letter(first_letter)
      form.secondMDC = get_letter(second_letter)


      page = @agent.submit(form, form.buttons.last)
      #puts page.at('div.alert')

    end


    def card_number_set(set=0)
      set = set * 4
      @card_number.to_s.split(//).map{|a|a.to_i}.slice(set,4).join.to_i
    end

    def get_letter(letter)
      @memorable_word.to_s[letter-1]
    end
  end
end
