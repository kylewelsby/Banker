# -*- encoding: utf-8 -*-
require 'rubygems'
require 'mechanize'
require 'logger'
require 'csv'

module Banker
  module Stratagies

    # This class allows the data retrieval of account balaces
    # for Capital One UK
    #
    # == Examples
    #
    # Make a new connection
    #
    #     bank = Banker::Stratagies::CapitalOneUK.new(:username => "Joe", :password => "password")
    #
    #     data = bank.get_data
    #
    #     data.balance.amount #=> 4100.10

    class CapitalOneUK
      attr_accessor :username, :password, :agent, :csv, :balance, :limit, :transactions

      LOGIN_ENDPOINT = "https://www.capitaloneonline.co.uk/CapitalOne_Consumer/Login.do"
      
      def initialize(args)
        @username = args[:username]
        @password = args[:password]

        @agent = Mechanize.new
        @agent.log = Logger.new 'mech.log'
        @agent.user_agent = 'Mozilla/5.0 (Banker)'
        @agent.force_default_encoding = 'utf8'


        authenticate
      end

private

      def authenticate
        page = @agent.get(LOGIN_ENDPOINT)

        form = page.form('logonForm')

        form.username = @username
        form.password = @password

        page = @agent.submit(form, form.buttons.first)
        
        @limit = page.at("table[summary='account summary'] tr:nth-child(1) td.normalText:nth-child(2)").content.gsub(/\D/,'').to_i
        @balance = -page.at("table[summary='account summary'] tr:nth-child(2) td.normalText:nth-child(2)").content.gsub(/\D/,'').to_i

        form = page.form('DownLoadTransactionForm')

        form.downloadType = 'csv'

        csv = @agent.submit(form, form.buttons.first)
        begin
          @transactions = CSV.parse(csv.body.gsub(/,\s*/, ','), :headers => true, :col_sep => ',')
        rescue CSV::IllegalFormatError => e
        end
      end

    end
  end
end
