module Banker
  class Base
    attr_writer :keys
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
      @agent.get(url)
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
  end
end
