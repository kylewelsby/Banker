module Banker
  class Transaction < Base
    attr_accessor :description, :amount, :transacted_at, :uid, :type

    def initialize(args={})
      @keys = %w{amount transacted_at}
      params(args)

      args.each do |attribute, value|
        send(:"#{attribute}=", value)
      end
    end
  end
end
