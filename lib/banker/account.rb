module Banker
  class Account
    attr_accessor :name, :uid, :amount, :limit
    def initialize(args = {})
      raise Banker::Error::InvalidParams, "missing attribute `name`" unless args.has_key?(:name)
      raise Banker::Error::InvalidParams, "missing attribute `uid`" unless args.has_key?(:uid)
      raise Banker::Error::InvalidParams, "missing attribute `amount`" unless args.has_key?(:amount)

      @name = args[:name]
      @uid = args[:uid]
      @amount = args[:amount]
      @limit = args[:limit]
    end
  end
end
