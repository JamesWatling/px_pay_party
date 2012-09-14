PxPayParty
==========

This is a very small library I wrote when trying to integrate a couple
of rails apps with PxPay from Payment Express. It uses the HTTParty
library to do all the heavy lifting.

It provides two class methods: payment_url_for and payment_response

Which you use in the following way:

PxPayParty.payment_url_for(:amount => 2.50, 
                           :merchant_reference => '1234', 
                           :return_url => finish_payments_url)

This returns a url which you send the user to so they can enter their
credit card details. 

PxPayParty.payment_response(params[:result])

This returns the response from PxPay so you know if the payment was
successful or not.

How I recommend you use this:

Something about your Gemfile
============================

Setup Your API Keys for each environment
========================================

Add the following into config/environments/development.rb and config/environments/test.rb

PX_PAY_USER_ID = 'PXPayUsername'
PX_PAY_KEY = 'YourPxPayAPIKey1234567890asdfghjkl'

Then create create config/initializers/px_pay_party.rb with the
following:

PX_PAY_PARTY_SETTINGS = { :currency => 'NZD',
                          :px_pay_user_id => PX_PAY_USER_ID,
                          :px_pay_key => PX_PAY_KEY}


Create a Payments Controller to talk to PXPay
====================================

You can start with something like this.

class PaymentsController < ApplicationController
  def start
    @invoice = Invoice.find params[:invoice_id]
    redirect_to PxPayParty.
      payment_url_for(:amount => @invoice.amount,
                      :merchant_reference => @invoice.id, 
                      :return_url => finish_payment_url)

  end

  def finish
    result = PxPayParty.payment_response(params[:result])

    if result['Success'] == '1'
      @invoice = Invoice.find result['MerchantReference']
      @invoice.paid!
      render :success
    else
      render :failure
    end
  end
end

Create routes to your Payments Controller
=========================================

in config/routes.rb:

get 'payment/start' => 'payments#start', as: 'start_payment'
get 'payment/finish' => 'payments#finish', as: 'finish_payment'


Create cucumber specs to test the thing
=======================================

Something like

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
