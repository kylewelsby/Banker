module Banker
  module Error
    class BankerError < Exception; end
    class InvalidParams < BankerError; end
    class FormMissing < BankerError
      def initialize(msg = "It appear that the form is missing. Please raise a GitHub issue https://github.com/kylewelsby/banker/issues")
        super(msg)
      end
    end
  end
end
