module Banker
  class LloydsTSBUK < Base

    LOGIN_URL = "https://online.lloydstsb.co.uk/personal/logon/login.jsp"
    COLLECT_URL = "https://secure2.lloydstsb.co.uk/personal/a/account_overview_personal/"

    attr_accessor :accounts

    FIELD = {
      username: 'frmLogin:strCustomerLogin_userID',
      password: 'frmLogin:strCustomerLogin_pwd',
      memorable_word: [
        'frmentermemorableinformation1:strEnterMemorableInformation_memInfo1',
        'frmentermemorableinformation1:strEnterMemorableInformation_memInfo2',
        'frmentermemorableinformation1:strEnterMemorableInformation_memInfo3'
      ]
    }

    def initialize(args={})
      @keys = %w(username password memorable_word)

      params(args)
      @username = args.delete(:username)
      @password = args.delete(:password)
      @memorable_word = args.delete(:memorable_word)

      @accounts = []

      authenticate!
      delivery!
    end

  private

    def authenticate!
      page = get(LOGIN_URL)
      form = page.form_with(action: '/personal/primarylogin')

      form[FIELD[:username]] = @username
      form[FIELD[:password]] = @password

      page = @agent.submit(form, form.buttons.first)

      form = page.form_with(action: '/personal/a/logon/entermemorableinformation.jsp')
      letters = memorable_required(page).delete_if { |v| v if v == 0 }

      form[FIELD[:memorable_word][0]] = '&nbsp;' + get_letter(@memorable_word, letters[0])
      form[FIELD[:memorable_word][1]] = '&nbsp;' + get_letter(@memorable_word, letters[1])
      form[FIELD[:memorable_word][2]] = '&nbsp;' + get_letter(@memorable_word, letters[2])

      @agent.submit(form, form.buttons.first)
    end

    def name(page)
      page.search('div.accountDetails h2').collect do |a|
        a.content.downcase.gsub(/\s/, '_').to_sym
      end
    end

    def identifier(page)
      page.search('div.accountDetails p.numbers').collect do |n|
        n.content.split(',').map { |d| cleaner(d) }
      end
    end

    def balance(page)
      bal = page.search('div.balanceActionsWrapper p.balance').collect {|b| b.content }

      bal.map do |b|
        resp = cleaner(b)
        resp.empty? ? 0.00 : resp.to_i
      end
    end

    def limit(page)
      page.search('div.accountBalance').inject([]) do |acc, b|
        if b.content.downcase.include?('limit')
          acc << cleaner(b.content.scan(/[\d.]+$/).first)
        else
          acc << 0.00
        end
        acc
      end
    end

    def delivery!
      page = get(COLLECT_URL)
      name(page).zip(balance(page), identifier(page), limit(page)).each_with_index do |acc, index|
        next if acc[2].nil?
        uid = Digest::MD5.hexdigest("LloydsTSBUK#{acc[2].last}")
        @accounts << Banker::Account.new(uid: uid,
                                         name: "#{acc[0]}",
                                         limit: acc[3],
                                         amount: acc[1],
                                         currency: 'GBP'
                                        )
      end
    end

  end
end
