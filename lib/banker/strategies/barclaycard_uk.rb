require 'rubygems'
require 'mechanize'
require 'logger'

module Banker
  module Strategies

    # This class allows the retrieval of account data
    # for Barcalycard UK
    #
    # == Examples
    #
    # Get OFX from Barcalycard UK
    #
    #     bank = Banker::Strategies::BarcalycardUK.new(:username => "joe"
    #     :passcode => '123456',
    #     :memorable_word => 'superduper')
    #
    #     bank.balance #=> 410010
    #
    class BarclaycardUK
      attr_accessor :username, :passcode, :memorable_word, :agent, :ofx, :balance

      LOGIN_ENDPOINT = 'https://bcol.barclaycard.co.uk/ecom/as2/initialLogon.do'
      EXPORT_ENDPOINT = 'https://bcol.barclaycard.co.uk/ecom/as2/export.do?doAction=processRecentExportTransaction&type=OFX_2_0_2&statementDate=&sortBy=transactionDate&sortType=Dsc'

      def initialize(args)
        @username = args[:username]
        @passcode = args[:passcode]
        @memorable_word = args[:memorable_word]

        @agent = Mechanize.new
        @agent.log = Logger.new 'mech.log'
        @agent.user_agent = 'Mozilla/5.0 (Banker)'

        authenticate

        @balance = @ofx.account.balance.amount_in_pennies
      end
      private

      def authenticate
        page = @agent.get(LOGIN_ENDPOINT)
        form = page.form_with(:action => '/ecom/as2/initialLogon.do')

        form.username = @username
        form.password = @passcode

        page = @agent.submit(form, form.buttons.last)

        form = page.form_with(:action => '/ecom/as2/validateMemorableWord.do')

        first_letter = page.at("label[for='lettera']").content.scan(/\d+/).first.to_i
        second_letter = page.at("label[for='letterb']").content.scan(/\d+/).first.to_i

        form.firstAnswer = get_letter(first_letter).upcase
        form.secondAnswer = get_letter(second_letter).upcase

        page = @agent.submit(form, form.buttons.first)

        #puts page.at("div.errorSummary")

        ofx = @agent.get EXPORT_ENDPOINT

        # Hack to downgrade version of OFX

        ofx = ofx.body.gsub('VERSION="202"','VERSION="200"')

        @ofx = OFX(ofx)
      end
      def get_letter(letter)
        @memorable_word.to_s[letter-1]
      end

    end
  end
end
