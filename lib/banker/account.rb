module Banker
  class Account < Base
    attr_accessor :name, :uid, :amount, :limit, :currency, :transactions
    def initialize(args = {})
      @keys = %w(name uid amount)
      params(args)
      @transactions = []

      args.each do |attribute, value|
        send(:"#{attribute}=", value)
      end
    end
  end
end
