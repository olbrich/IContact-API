class DevelApi < Icontact::Api
  API_USERNAME='kolbrich'
  API_PASSWORD='kolbrichapi'
  API_KEY = 'TFt7B1i4S3m8e96Xex26NBUXiD2XBOTl'
  API_SECRET = 'jciK4qEMkRKpQGdV46SIxCvG6oux2dIb'
  DOMAIN = "http://app.kolbrich.devel.icp/icp"

  def initialize(username = DevelApi::API_USERNAME, password = DevelApi::API_PASSWORD)
    super(API_USERNAME, API_PASSWORD)
    self.key = API_KEY
    self.secret = API_SECRET
  end
  
end


class BetaApi < Icontact::Api
  API_USERNAME='kolbrich'
  API_PASSWORD='1234567890'
  API_KEY = 'mK9ET3qVMUI6VmBrLxFOMVYNqtEDmL5y'
  API_SECRET = 'l525YjQA4pxQBY7dlCSXoGBF058cG4AR'
  DOMAIN = "http://app.beta.icontact.com/icp"

  def initialize(username = BetaApi::API_USERNAME, password = BetaApi::API_PASSWORD)
    super(username, password)
    self.key = API_KEY
    self.secret = API_SECRET
    self.domain = DOMAIN
  end
  
end

