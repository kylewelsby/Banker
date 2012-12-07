module Banker
  class Account < Base
    attr_accessor :name, :uid, :amount, :limit, :currency
    def initialize(args = {})
      @keys = %w(name uid amount)
      params(args)

      @name = args[:name]
      @uid = args[:uid]
      @amount = args[:amount]
      @limit = args[:limit]
      @currency = args[:currency]
    end
  end
end
