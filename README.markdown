PxPayParty
==========

Is a small wrapper I wrote to integrate Rails apps with PxPay from Payment Express. 
It uses the HTTParty gem to do all the heavy lifting, hence the name.

What does it do?
================

It provides two class methods.

payment_url_for returns a url which you send the user to so they can enter their credit card details. 

    PxPayParty.payment_url_for(:amount => 2.50, 
                               :merchant_reference => '1234', 
                               :return_url => finish_payments_url)


payment_response returns the response from PxPay so you know if the payment was successful or not.

    PxPayParty.payment_response(params[:result])


Integrating into your Rails app
===============================

Add to your Gemfile
----------------------------

gem 'px_pay_party'


Setup your API keys
-------------------

Add the following into config/environments/development.rb (and so on)

    PX_PAY_USER_ID = 'PXPayUsername_Dev'
    PX_PAY_KEY = 'YourPxPayAPIKey1234567890asdfghjkl'

And create config/initializers/px_pay_party.rb containing:

    PX_PAY_PARTY_SETTINGS = { :currency => 'NZD',
                              :px_pay_user_id => PX_PAY_USER_ID,
                              :px_pay_key => PX_PAY_KEY }


Create a payments controller
----------------------------

You can start with something like this.

    class PaymentsController < ApplicationController
      def start
        @order = Order.find params[:order_id]
        redirect_to PxPayParty.
            payment_url_for(:amount => @order.amount,
                            :merchant_reference => @order.id, 
                            :return_url => finish_payment_url)
      end

      def finish
        result = PxPayParty.payment_response(params[:result])

        if result['Success'] == '1'
          @order = Order.find result['MerchantReference']
          @order.paid!
          render :success
        else
          render :failure
        end
      end
    end

Create routes to your payments controller
-----------------------------------------

    get 'payment/start' => 'payments#start', as: 'start_payment'
    get 'payment/finish' => 'payments#finish', as: 'finish_payment'

Link to make payment
--------------------

I think this is getting a bit obvious, however, use this in your view:

    link_to('Make payment', start_payment_path(order_id: @order.id))


Here is a cheat for testing via cucumber, capybara, selenium
---------------------------------------

    Then /^I should see I am being charged the full amount$/ do
      current_url.should =~ /paymentexpress\.com/
      page.should have_content '$50.00'
    end

    When /^I enter my credit card details$/ do
      fill_in 'CardNum', :with => '4111111111111111'
      fill_in 'ExMnth', :with => '12'
      fill_in 'ExYr', :with => '20'
      fill_in 'NmeCard', :with => 'Testbert Testrie'
      fill_in 'Cvc2', :with => '911'
      click_on 'submitImageButton'
    end

    Then /^I should see that payment was successful$/ do
      page.should have_content 'APPROVED'
      click_on 'Click Here to Proceed to the Next step'
    end


