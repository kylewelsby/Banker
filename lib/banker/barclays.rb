module Banker
  class Barclays < Base

    LOGIN_URL = "https://bank.barclays.co.uk/olb/auth/LoginLink.action"
    EXPORT_URL = "https://bank.barclays.co.uk/olb/balances/ExportDataStep1.action"

    attr_accessor :accounts, :ofx

    FIELD = {
      surname: "surname",
      membership_number: "membershipNumber",
      passcode: 'passcode',
      memorable_word: [
        'firstMemorableCharacter',
        'secondMemorableCharacter'
      ]
    }

    def initialize(args={})
      @keys = %w(surname membership_number passcode memorable_word)

      params(args)
      @surname = args.delete(:surname)
      @membership_number = args.delete(:membership_number)
      @passcode = args.delete(:passcode)
      @memorable_word = args.delete(:memorable_word)

      @accounts = []

      authenticate!
      delivery(download!)
    end

  private

    def authenticate!
      page = get(LOGIN_URL)
      form = page.form_with(action: 'LoginLink.action')

      form[FIELD[:surname]] = @surname
      form[FIELD[:membership_number]] = @membership_number

      page = @agent.submit(form, form.buttons.first)

      form = page.form_with(action: 'LoginStep1i.action')
      form.radiobuttons.first.check
      page = @agent.submit(form, form.buttons.first)

      form = page.form_with(action: 'LoginStep2.action')
      letters = memorable_required(page).delete_if { |v| v if v == 0 }

      form[FIELD[:passcode]] = @passcode
      form[FIELD[:memorable_word][0]] = get_letter(@memorable_word, letters[0])
      form[FIELD[:memorable_word][1]] = get_letter(@memorable_word, letters[1])

      @agent.submit(form, form.buttons.first)
    end

    def memorable_required(page)
      page.labels.collect { |char| cleaner(char.to_s).to_i }
    end

    def cleaner(str)
      str.gsub(/[^\d+]/, '')
    end

    def download!
      page = get(EXPORT_URL)
      form = page.form_with(action: "/olb/balances/ExportDataStep1.action")
      form['reqSoftwarePkgCode'] = '6'
      form['productIdentifier'] = 'All'
      page = @agent.submit(form, form.buttons.first)
      form = page.form_with(:action => "/olb/balances/ExportDataStep2All.action")
      file = @agent.submit(form, form.buttons.last)
      return OFX(file.body)
    end

    def delivery(ofx)
      ofx.bank_accounts.each_with_object(@accounts) do |account, accounts|
        args = { uid: Digest::MD5.hexdigest("Barclays#{@membership_number}#{account.id}"),
                 name: "Barclays #{account.id[-4,4]}",
                 amount: account.balance.amount_in_pennies,
                 currency: account.currency }

        accounts << Banker::Account.new(args)
      end
    end

  end
end
