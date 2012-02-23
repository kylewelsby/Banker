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

        memorable_set(page, form)

        page = @agent.submit(form, form.buttons.first)

        # Accounts Page
        an = page.search('div.accountDetails h2').collect {|a| a.content }
        ad = page.search('div.accountDetails p.numbers').collect {|n| n.content }
        ab = page.search('div.balanceActionsWrapper p.balance').collect {|b| b.content }

        fd = ad.map { |detail| detail.split(',').map { |d| cleaner(d) } }

        fb = ab.map { |b| cleaner(b) }

        response = []
        an.zip(fb, fd).each_with_index do |acc, index|
          response << { "#{acc[0]}" => { balance: acc[1], details: acc[2] } }
        end

        puts response.inspect

      end

      def memorable_letters(page)
        {
          first: memorable_required(page)[0],
          second: memorable_required(page)[1],
          third: memorable_required(page)[2]
        }
      end

      def memorable_set(page, form)
        letters = memorable_letters(page)

        form.fields[2].value = '&nbsp;' + get_memorable_word_letter(letters.fetch(:first))
        form.fields[3].value = '&nbsp;' + get_memorable_word_letter(letters.fetch(:second))
        form.fields[4].value = '&nbsp;' + get_memorable_word_letter(letters.fetch(:third))
      end

      def memorable_required(page)
        page.labels.collect { |char| cleaner(char.to_s) }
      end

      def get_memorable_word_letter(letter)
        @memorable_word.to_s[letter.to_i - 1]
      end

      def cleaner(str)
        str.gsub(/[^\d+]/, '')
      end

    end
  end
end
