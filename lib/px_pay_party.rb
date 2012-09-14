require 'httparty'

class PxPayParty
  include HTTParty
  API_URL = 'https://sec.paymentexpress.com/pxpay/pxaccess.aspx'
  #format :xml

  #def self.setup(settings)
    #@@settings = settings
  #end

  def self.payment_url_for(params)
    reply_xml = post(API_URL, :body => generate_request_xml(params))
    reply = Hash.from_xml(reply_xml)
    reply['Request']['URI']
  end

  def self.payment_response(result)
    reply_xml = post(API_URL, :body => process_response_xml(result))
    Hash.from_xml(reply_xml)['Response']
  end

  private
  # the structure to send when requesting a payment
  def self.generate_request_xml(params)
    {'PxPayUserId' => PX_PAY_PARTY_SETTINGS[:px_pay_user_id],
     'PxPayKey' => PX_PAY_PARTY_SETTINGS[:px_pay_key],
     'AmountInput' => format_amount(params[:amount].to_f),
     'CurrencyInput' => (params[:currency] || PX_PAY_PARTY_SETTINGS[:currency]),
     'MerchantReference' => params[:merchant_reference],
     'TxnType' => 'Purchase',
     'UrlFail' => params[:return_url],
     'UrlSuccess' => params[:return_url] }.
     to_xml(:root => 'GenerateRequest')
  end

  # the structure to send when requesting a payment result
  def self.process_response_xml(result)
    {'PxPayUserId' => PX_PAY_PARTY_SETTINGS[:px_pay_user_id],
     'PxPayKey' => PX_PAY_PARTY_SETTINGS[:px_pay_key],
     'Response' => result}.
     to_xml(:root => 'ProcessResponse')
  end


  def self.format_amount(amount)
    #warning: frightening
    str = (amount.round(2)*100).to_i.to_s
    "#{str[0,(str.length - 2)]}.#{str[(str.length - 2), str.length]}"
  end
end

  #def payment_success
    #reply = Nestful.post PXPAYURI, :format => :xml, :body => process_response_xml(params[:result]).target!
    #if reply['valid'] == '1'
      #resource.commission_paid = true
      #resource.save
    #end

    ##now send processResponse
  #end

  #def payment_fail
    ##reply = Nestful.post PXPAYURI, :format => :xml, :body => process_response_xml(params[:result]).target!
    ##Pxpayresponse.create(reply)
  #end

  #protected
  #def redirect_unless_commission_set
    #unless resource.commission
      #flash[:error] = "You are unable to make a payment at this time"
      #redirect_to [:employer, resource]
    #end
  #end

  #def process_response_xml(r)
    #b = Builder::XmlMarkup.new
    #b.ProcessResponse do |b|
      #b.PxPayUserId(PXPAYUSERID)
      #b.PxPayKey(PXPAYKEY)
      #b.Response(r)
    #end
    #b
  #end
#
