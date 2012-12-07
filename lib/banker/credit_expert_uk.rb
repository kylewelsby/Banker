module Banker
  # This class allows the retrieval of credit score data
  # for Credit Expert UK
  #
  # == Examples
  #
  # Get Score from Credit Expert UK
  #
  #     site = Banker::CreditExpertUK.new(:username => "joe",
  #     :password => '123456',
  #     :memorable_word => 'superduper')
  #
  #     site.score #=> 800
  #
  class CreditExpertUK < Base
    attr_accessor :username, :password, :memorable_word, :agent, :score

    LOGIN_ENDPOINT = "https://www.creditexpert.co.uk/MCCLogin.aspx"

    FIELDS = {
      username: 'loginUser:txtUsername:ECDTextBox',
      password: 'loginUser:txtPassword:ECDTextBox',
      questions: [
        'label span#loginUserMemorableWord_SecurityQuestionLetter1',
        'label span#loginUserMemorableWord_SecurityQuestionLetter2'
      ],
      answers: [
        'loginUserMemorableWord:SecurityQuestionUK1_SecurityAnswer1_ECDTextBox',
        'loginUserMemorableWord:SecurityQuestionUK1_SecurityAnswer2_ECDTextBox'
      ],
      score: 'span#MCC_ScoreIntelligence_ScoreIntelligence_Dial1_MyScoreV31_pnlMyScore1_lblMyScore'
    }

    def initialize(args)
      @keys = %w(username password memorable_word)
      params(args)
      @username = args[:username]
      @password = args[:password]
      @memorable_word = args[:memorable_word]

      authenticate
    end

    private

    def authenticate
      @score = data
    end

    def start
      page = get(LOGIN_ENDPOINT)

      form = page.form_with(:action => 'MCCLogin.aspx')

      form[FIELDS[:username]] = @username
      form[FIELDS[:password]] = @password

      @agent.submit(form, form.buttons.first)
    end

    def step1
      page = start
      form = page.form_with(name: 'MasterPage')
      raise MissingForm if form.nil?

      first_letter = extract_digit(page.at(FIELDS[:questions][0]).content)
      second_letter = extract_digit(page.at(FIELDS[:questions][1]).content)

      form[FIELDS[:answers][0]] = get_letter(first_letter)
      form[FIELDS[:answers][1]] = get_letter(second_letter)

      @agent.submit(form, form.buttons.first)
    end

    def data
      step1.at(FIELDS[:score]).content.to_i
    end

    def extract_digit(content)
      content.scan(/\d+/).first.to_i
    end

    def get_letter(index)
      @memorable_word[index-1]
    end
  end
end
