Gem::Specification.new do |s|
  s.name        = 'px_pay_party'
  s.version     = '0.0.0'
  s.date        = '2012-09-14'
  s.summary     = "An API wrapper for PxPay from Payment Express"
  s.description = "A small lib to save you thinking when implementing PxPay for a ruby app"
  s.authors     = ["Rob Guthrie"]
  s.email       = 'rob@guthr.ie'
  s.files       = ["lib/px_pay_party.rb"]
  s.homepage    = 'http://github.com/robguthrie/px_pay_party'
  s.add_runtime_dependency 'httparty'
end
