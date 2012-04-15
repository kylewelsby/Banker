module Banker
  # This class allows the retrieval of account data
  # for Barcalycard UK
  #
  # == Examples
  #
  # Get OFX from Barcalycard UK
  #
  #     bank = Banker::BarcalycardUK.new(:username => "joe"
  #     :password => '123456',
  #     :memorable_word => 'superduper')
  #
  #     bank.accounts.first.balance #=> 410010
  #
  class BarclaycardUK < Base
    attr_accessor :username, :password, :memorable_word, :accounts, :page

    LOGIN_ENDPOINT = 'https://bcol.barclaycard.co.uk/ecom/as2/initialLogon.do'
    EXPORT_ENDPOINT = 'https://bcol.barclaycard.co.uk/ecom/as2/export.do?doAction=processRecentExportTransaction&type=OFX_2_0_2&statementDate=&sortBy=transactionDate&sortType=Dsc'
    FIELDS = {
      username: 'username',
      password: 'password',
      memorable_word: [
        'firstAnswer',
        'secondAnswer'
      ]
    }

    def initialize(args = {})
      @keys = [:username, :password, :memorable_word]
      params(args)
      @username = args[:username]
      @password = args[:password]
      @memorable_word = args[:memorable_word]

      @accounts = []

      authenticate!

      get_data
    end
    private

    def authenticate!
      page = get(LOGIN_ENDPOINT)
      form = page.form_with(:action => '/ecom/as2/initialLogon.do')

      form[FIELDS[:username]] = @username
      form[FIELDS[:password]] = @password

      @page = @agent.submit(form, form.buttons.last)
      step2(@page)
    end

    def step2(page)

      form = page.form_with(:action => '/ecom/as2/validateMemorableWord.do')

      first_letter = page.at("label[for='lettera']").content.
        scan(/\d+/).first.to_i
      second_letter = page.at("label[for='letterb']").content.
        scan(/\d+/).first.to_i

      form[FIELDS[:memorable_word][0]] = get_letter(@memorable_word,
                                                    first_letter).upcase
      form[FIELDS[:memorable_word][1]] = get_letter(@memorable_word,
                                                    second_letter).upcase

      @page = @agent.submit(form, form.buttons.first)
      @limit = -@page.at(".panelSummary .limit .figure").content.
        gsub(/\D/,'').to_i
    end

    def get_data
      ofx = get(EXPORT_ENDPOINT)
      ofx = ofx.body.gsub('VERSION="202"','VERSION="200"')

      @ofx = OFX(ofx)

      resource = StringIO.new(ofx)
      html = Nokogiri::HTML.parse(
        Iconv.conv("UTF-8", "LATIN1//IGNORE",resource.read)
      )
      account_id = html.search("ccacctfrom > acctid").inner_text
      currency = html.search("ccstmtrs > curdef").inner_text

      uid = Digest::MD5.hexdigest("Barclayard#{@username}#{account_id}")
      @accounts << Banker::Account.new(uid: uid,
                          name: "Barclaycard",
                          amount: @ofx.account.balance.amount_in_pennies,
                          currency: currency,
                          limit: @limit
                         )
    end
  end
end
