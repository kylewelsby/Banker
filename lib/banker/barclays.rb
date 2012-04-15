module Banker
  class Barclays < Base

    LOGIN_URL = "https://bank.barclays.co.uk/olb/auth/LoginLink.action"

    attr_accessor :accounts

    FIELD = {
      surname: "surname",
      membership_number: "membershipNumber",
      passcode: 'passcode'
    }

    def initialize(args={})
      @keys = %w(surname membership_number passcode memorable_word)

      params(args)
      @surname = args.delete(:surname)
      @membership_number = args.delete(:membership_number)
      @passcode = args.delete(:passcode)
      @memorable_word = args.delete(:memorable_word)

      authenticate!
    end

    class Account < Barclays
      attr_accessor :name, :amount

      def initialize(account_id, agent)

      end
    end

  private

    def authenticate!
      stage_three(stage_two(stage_one))
    end

    def stage_one
      page = get(LOGIN_URL)
      form = page.form_with(action: 'LoginLink.action')

      form[FIELD[:surname]] = @surname
      form[FIELD[:membership_number]] = @membership_number

      @agent.submit(form, form.buttons.first)
    end

    def stage_two(page)
      form = page.form_with(action: 'LoginStep1i.action')
      form.checkbox_with('passcode').check
      @agent.submit(form, form.buttons.first)
    end

    def stage_three(page)
      form = page.form_with(action: 'LoginStep2.action')
      memorable = memorable_required(page)
      puts "#{'*'*10} [stage_three(page)] #{memorable.inspect}"

      form[FIELD[:passcode]] = @passcode
    end

    def memorable_required(page)
      puts "#{'*'*10} [memorable_required(page)] #{page.inspect}"
      page.labels.collect { |char| cleaner(char.to_s) }
    end

    def cleaner(str)
      str.gsub(/[^\d+]/, '')
    end

  end
end
