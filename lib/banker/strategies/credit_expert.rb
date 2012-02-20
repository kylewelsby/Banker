module Banker
  module Strategies
    class CreditExpert
      attr_accessor :username, :password, :memorable_word, :agent, :score

      LOGIN_ENDPOINT = "https://www.creditexpert.co.uk/MCCLogin.aspx"

      def initialize(args)
        @username = args[:username]
        @password = args[:password]
        @memorable_word = args[:memorable_word]

        @agent = Mechanize.new
        @agent.log = Logger.new 'mech.log'
        @agent.user_agent = 'Mozilla/5.0 (Banker)'

        authenticate
      end

      private

      def authenticate
        page = @agent.get(LOGIN_ENDPOINT)

        form = page.form_with(:action => 'MCCLogin.aspx')

        form['loginUser:txtUsername:ECDTextBox'] = @username
        form['loginUser:txtPassword:ECDTextBox'] = @password


        page = @agent.submit(form, form.buttons.first)

        form = page.form_with(:name => 'MasterPage')

        first_letter = page.at('label span#loginUserMemorableWord_SecurityQuestionLetter1').content.scan(/\d+/).first.to_i
        second_letter = page.at('label span#loginUserMemorableWord_SecurityQuestionLetter2').content.scan(/\d+/).first.to_i

        form['loginUserMemorableWord:SecurityQuestionUK1_SecurityAnswer1_ECDTextBox'] = get_letter(first_letter)

        form['loginUserMemorableWord:SecurityQuestionUK1_SecurityAnswer2_ECDTextBox'] = get_letter(second_letter)

        page = @agent.submit(form, form.buttons.first)

        @score = page.at('span#MCC_ScoreIntelligence_ScoreIntelligence_Dial1_MyScoreV31_pnlMyScore1_lblMyScore').content.to_i

      end

      def get_letter(index)
        @memorable_word[index-1]
      end
    end
  end
end
