module Banker
  # This class allows the data retrieval of account balaces
  # for Capital One UK
  #
  # == Examples
  #
  # Make a new connection
  #
  #     bank = Banker::CapitalOneUK.new(:username => "Joe", :password => "password")
  #
  #     bank.accounts.first.balance.amount #=> 4100.10
  #
  class CapitalOneUK < Base
    attr_accessor :username, :password, :accounts
    attr_reader :page

    LOGIN_ENDPOINT = "https://www.capitaloneonline.co.uk/CapitalOne_Consumer/Login.do"
    FIELD = {
      username: 'username',
      password: [
        'password.randomCharacter0',
        'password.randomCharacter1',
        'password.randomCharacter2'
      ]
    }

    def initialize(args = {})
      @keys = ['username', 'password']
      params(args)
      @username = args[:username]
      @password = args[:password]

      @accounts = []

      authenticate!
      get_data
    end

    private

    def authenticate!
      page = get(LOGIN_ENDPOINT)

      form = page.form_with(name: 'logonForm')

      form[FIELD[:username]] = @username
      letters_html = page.at("#sign_in_box div:nth-child(3)").content
      letters = letters_html.scan(/(\d)/).collect { |letter| letter[0].to_i }

      form[FIELD[:password][0]] = get_letter(@password, letters[0])
      form[FIELD[:password][1]] = get_letter(@password, letters[1])
      form[FIELD[:password][2]] = get_letter(@password, letters[2])

      @page = @agent.submit(form, form.buttons.first)
    end

    #def letters
      #html = page.search('#sign_in_box .password').content
    #end

    def get_data
      limit = -@page.at("table[summary='account summary'] tr:nth-child(1) td.normalText:nth-child(2)").content.gsub(/\D/,'').to_i
      amount = -@page.at("table[summary='account summary'] tr:nth-child(2) td.normalText:nth-child(2)").content.gsub(/\D/,'').to_i
      account_number = @page.at("table:first-child tr:nth-child(5) td b").
        content.to_i

      uid = Digest::MD5.hexdigest("CapitalOneUK#{account_number}")

      @accounts << Banker::Account.new(name: "Capital Account (#{account_number.to_s[-4..-1]})",
                                       amount: amount,
                                       limit: limit,
                                       uid: uid,
                                       currency: "GBP"
                                      )

      #form = page.form('DownLoadTransactionForm')

      #form.downloadType = 'csv'

      #csv_data = @agent.submit(form, form.buttons.first)

      #csv = csv_data.body.gsub(/,\s*/, ',')

      #@transactions = CSV.parse(csv, :headers => true)
    end

  end
end
