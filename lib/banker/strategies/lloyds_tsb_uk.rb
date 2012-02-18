# -*- encoding: utf-8 -*-
require 'rubygems'
require 'mechanize'
require 'logger'
require 'csv'
require 'fastercsv'

module Banker
  module Stratagies

    # This class allows the data retrieval of account balaces
    # for Lloyds TSB UK 
    #
    # == Examples
    #
    # Make a new connection
    #
    #     bank = Banker::Stratagies::LloydsTSBUK.new(:username => "Joe", :password => "password")
    #
    #     data = bank.get_data
    #
    #     data.balance.amount #=> 4100.10
    class LloydsTSBUK
      # Think about account - for the accounts overview page
      attr_accessor :username, :password, :memorable_word, :agent, :csv, :balance, :limit, :transactions

      LOGIN_ENDPOINT = "https://online.lloydstsb.co.uk/personal/logon/login.jsp"
      MEMORABLE_ENDPOINT = "https://secure2.lloydstsb.co.uk/personal/a/logon/entermemorableinformation.jsp"

      def initialize(args)
        @username = args[:username]
        @password = args[:password]
        @memorable_word = args[:memorable_word]

        @agent = Mechanize.new
        @agent.log = Logger.new 'mech.log'
        @agent.user_agent = 'Mozilla/5.0 (Banker)'
        @agent.force_default_encoding = 'utf8'

        authenticate
      end

    private

      def authenticate
        # Go to Login Page
        login_page = @agent.get(LOGIN_ENDPOINT)

        # Submit the login form
        login_page.form('frmLogin') do |f|
          f.fields[0].value = @username
          f.fields[1].value = @password
        end.click_button

        # Go to Memorable Word Page
        memorable_page = @agent.get(MEMORABLE_ENDPOINT)

        # Get form
        memorable_form = memorable_page.form('frmentermemorableinformation1')

        # Find Required Letters
        letters = memorable_page.labels.
                    collect { |char| char.to_s.gsub(/[^\d+]/, '') }

        # Find Required Letter Select Inputs
        selects = memorable_form.fields.
                    collect { |field| field if field.name.include?("EnterMemorableInformation") }.compact

        # Set Memorable Word Select Inputs
        [0, 1, 2].each { |n| selects[n].value = letters[n] }

        # Submit Memorable Word Form
        memorable_form.click_button
      end

    end
  end
end