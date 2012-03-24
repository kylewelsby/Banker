module Banker
  # This class allows the data retrieval of accounts for Lloyds TSB UK
  #
  # == Examples
  #
  # Retrieve Account Balance
  #
  #     user_params = { username: 'Joe', password: 'password', memorable_word: 'superduper' }
  #     lloyds = Banker::LloydsTSBUK.new(user_params)
  #     lloyds.balance
  #     # => [ {:current_account => { :balance => 160940,
  #                                   :details => { :sort_code => "928277",
  #                                                 :account_number => "92837592" }}},
  #
  #            {:savings_account => { :balance => 0.0,
  #                                   :details => { :sort_code => "918260",
  #                                                 :account_number=>"91850261" }}},
  #
  #            {:lloyds_tsb_platinum_mastercard => { :balance => 0.0,
  #                                                  :details => { :card_number => "9284710274618391" }}}
  #          ]
  #
  class LloydsTSBUK
    attr_accessor :username, :password, :memorable_word, :balance, :agent

    LOGIN_ENDPOINT = "https://online.lloydstsb.co.uk/personal/logon/login.jsp"

    def initialize(args)
      @username = args[:username]
      @password = args[:password]
      @memorable_word = args[:memorable_word]

      @agent = Mechanize.new
      @agent.log = Logger.new 'mech.log'
      @agent.user_agent = 'Mozilla/5.0 (Banker)'
      @agent.force_default_encoding = 'utf8'

      @balance = authenticate
    end

    def get_memorable_word_letter(letter)
      @memorable_word.to_s[letter.to_i - 1]
    end

    def cleaner(str)
      str.gsub(/[^\d+]/, '')
    end

  private

    def authenticate
      page = @agent.get(LOGIN_ENDPOINT)

      # Login Page
      page = page.form('frmLogin') do |f|
        f.fields[0].value = @username
        f.fields[1].value = @password
      end.click_button

      # Memorable Word
      form = page.form('frmentermemorableinformation1')
      memorable_set(page, form)
      page = @agent.submit(form, form.buttons.first)

      # Accounts Page
      return account_return(page)
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

    def account_name(page)
      page.search('div.accountDetails h2').collect {|a| a.content.downcase.gsub(/\s/, '_').to_sym }
    end

    def account_detail(page)
      page.search('div.accountDetails p.numbers').collect {|n| n.content }
    end

    def account_balance(page)
      page.search('div.balanceActionsWrapper p.balance').collect {|b| b.content }
    end

    def formatted_detail(page)
      resp = account_detail(page).map { |detail| detail.split(',').map { |d| cleaner(d) } }
      resp.map! do |r|
        if r.length == 2
          { sort_code: r[0], account_number: r[1] }
        elsif r.length == 1
          { card_number: r[0] }
        else
          STDERR.puts "[Error] It seems we got account details that we did not expect! - #{r.inspect}"
        end
      end
    end

    def formatted_balance(page)
      account_balance(page).map do |b|
        resp = cleaner(b)
        resp.empty? ? 0.00 : resp.to_i
      end
    end

    def account_return(page)
      resp = []
      account_name(page).zip(formatted_balance(page), formatted_detail(page)).each_with_index do |acc, index|
        resp << { acc[0] => { balance: acc[1], details: acc[2] } }
      end
      resp
    end

  end
end
