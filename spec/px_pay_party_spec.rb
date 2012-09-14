require 'httparty'
require 'active_support'
require 'lib/px_pay_party'

PX_PAY_USER_ID = 'Username_dev'
PX_PAY_KEY = '0123456789abcdefg'

PX_PAY_PARTY_SETTINGS = { :currency => 'NZD',
                          :px_pay_user_id => PX_PAY_USER_ID,
                          :px_pay_key => PX_PAY_KEY}

describe PxPayParty do
  describe 'requesting a payment url' do

    it 'returns a url to send the client to so they can pay' do
      PxPayParty.should_receive(:post).
        and_return("<Request><URI>https://sec.paymentexpress.com/pxpay/pxpay.aspx?</URI></Request>" )
      url = PxPayParty.payment_url_for(:amount => '10.00',
                                       :return_url => '/payment_finished/',
                                       :merchant_reference => 'Order:5')

      url.should =~ /^https:\/\/sec\.paymentexpress\.com\/pxpay\/pxpay\.aspx\?/
    end

    it 'returns the result information of a payment' do
      PxPayParty.should_receive(:post).
        and_return("<Response><Success>1</Success></Response>\n" )
      result = PxPayParty.payment_response('some_result_id')
      result['Success'].should == '1'
    end
  end
end
