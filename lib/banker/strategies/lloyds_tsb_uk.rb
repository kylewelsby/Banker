module Banker
  module Stratagies

    # This class allows the data retrieval of accounts for Lloyds TSB UK
    #
    # == Examples
    #
    # Retrieve Account Balance
    #
    #     user_params = { username: 'Joe', password: 'password', memorable_word: 'superduper' }
    #     lloyds = Banker::Stratagies::LloydsTSBUK.new(user_params)
    #     lloyds.balance #=> { current: 4100.10, credit_card: 0 }
    #
    class LloydsTSBUK
      attr_accessor :username, :password, :memorable_word, :agent, :csv, :balance, :limit, :transactions

      LOGIN_ENDPOINT = "https://online.lloydstsb.co.uk/personal/logon/login.jsp"

      def initialize(args)
        @username = args[:username]
        @password = args[:password]
        @memorable_word = args[:memorable_word]

        @agent = Mechanize.new
        @agent.log = Logger.new 'mech.log'
        @agent.user_agent = 'Mozilla/5.0 (Banker)'
        @agent.force_default_encoding = 'utf8'

        authenticate
      end

    private

      def authenticate
        page = @agent.get(LOGIN_ENDPOINT)

        # Login Details
        page = page.form('frmLogin') do |f|
          f.fields[0].value = @username
          f.fields[1].value = @password
        end.click_button

        # Memorable Word
        form = page.form('frmentermemorableinformation1')

        first_letter = memorable_required(page)[0]
        second_letter = memorable_required(page)[1]
        third_letter = memorable_required(page)[2]

        form.fields[2].value = '&nbsp;' + get_memorable_word_letter(first_letter)
        form.fields[3].value = '&nbsp;' + get_memorable_word_letter(second_letter)
        form.fields[4].value = '&nbsp;' + get_memorable_word_letter(third_letter)

        page = @agent.submit(form, form.buttons.first)

        # Accounts Page
        accounts_count = page.search("ul.myAccounts ul.miniStatement").size
        
        account_names = page.search('div.accountDetails h2').collect {|account| account.content }
        account_details = page.search('div.accountDetails p.numbers').collect {|num| num.content }
        account_balance = page.search('div.balanceActionsWrapper p.balance').collect {|bal| bal.content }
        # account_limit = page.search('div.balanceActionsWrapper p.accountMsg').collect {|bal| bal.content }

        formatted_account_details = account_details.map do |detail|
          { details: detail.split(',').map { |d| d.gsub!(/[^\d+]/, '') } }
        end

        formatted_account_balance = account_balance.map do |bel|
          { balance: bel.gsub!(/[^\d+]/, '') }
        end

        # formatted_account_limit = account_limit.map do |l|
          # { limit: l.gsub!(/[^\d+]/, '') }
        # end

        account_names.zip(formatted_account_balance, formatted_account_details).inspect

      end

      def memorable_required(page)
        page.labels.collect { |char| char.to_s.gsub(/[^\d+]/, '') }
      end

      def get_memorable_word_letter(letter)
        @memorable_word.to_s[letter.to_i - 1]
      end

    end
  end
end
