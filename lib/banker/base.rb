module Banker
  class Base
    attr_writer :keys, :agent
    def params(args)
      missing_keys = []
      return unless defined? @keys
      @keys.each do |key|
        missing_keys << key unless args.has_key?(key.to_sym)
      end
      if missing_keys.any?
        raise Error::InvalidParams,
          "missing parameters #{missing_keys.map {|key| "`#{key}` "}.join}"
      end
    end

    def get(url)
      @agent ||= Mechanize.new
      @agent.log = Logger.new 'banker.log'
      @agent.user_agent = "Mozilla/5.0 (Banker)"
      @agent.force_default_encoding = "utf8"
      @agent.agent.http.ssl_version = :SSLv3
      @agent.get(url)
    end

    def class_name
      self.class.name.split("::").last
    end

    def get_letter(value,index)
      value.to_s[index-1]
    end

    def memorable_required(page)
      page.labels.collect { |char| cleaner(char.to_s).to_i }
    end

    def cleaner(str)
      str.gsub(/[^\d+]/, '')
    end

    def parse_ofx(type='bank_account')
      if type == 'credit_card'
        _accounts = ofx.credit_cards
      elsif type == 'bank_account'
        _accounts = ofx.bank_accounts
      end
      _accounts.each_with_object(@accounts) do |account, accounts|
        args = { uid: Digest::MD5.hexdigest("#{class_name}#{@membership_number}#{account.id}"),
                 name: "#{class_name} #{account.id[-4..-1]}",
                 amount: account.balance.amount_in_pennies,
                 currency: account.currency }
        e_account = Banker::Account.new(args)
        account.transactions.each do |transaction|
          transaction_args = {
            :amount => transaction.amount_in_pennies,
            :description => transaction.name,
            :transacted_at => transaction.posted_at,
            :uid => transaction.fit_id,
            :type => transaction.type
          }
          e_transaction = Banker::Transaction.new(transaction_args)
          e_account.transactions << e_transaction
        end
        e_account.transactions.sort_by {|k,v| k.transacted_at}.reverse
        accounts << e_account
      end
    end
  end
end
