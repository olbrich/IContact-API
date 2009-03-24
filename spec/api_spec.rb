require File.dirname(__FILE__) + '/spec_helper.rb'

describe Icontact::Api do
  before(:each) do
    @mock_time = mock('Time', :getgm => 999999)
    Time.stub!(:now).and_return(@mock_time)
    Kernel.stub!(:rand).and_return(111)    
  end

  describe "api" do
    before(:each) do
      @api = Icontact::Api.new('mock_username', 'mock_password')
      @response = mock('response',:code=>200, :body=>"body")
      @mock_http_request = mock('http', :request=>@response)
      Net::HTTP.stub!(:start).and_yield(@mock_http_request)
    end
    
    describe "an http request", :shared=>true do
      it "should apply headers to the request" do
        @mock_request = mock("Request", :body= => true)
        @api.should_receive(:apply_headers).and_return(@mock_request)
        do_request
      end
    
      it "should package query params" do
        @api.class.should_receive(:package_query_params)
        do_request(:limit=>10)
      end
      
      it "should send the request" do
        Net::HTTP.should_receive(:start)
        do_request
      end
      
      it "should parse the server response into a hash" do
        @api.class.should_receive(:parse_response)
        do_request
      end      
    end
    
    describe "an http request with a body", :shared=>true do
      it_should_behave_like "an http request"
      
      it "should package the data into the body" do
        @api.class.should_receive(:body_encoder)
        do_request
      end
    end
            
    describe ".get" do
      
      def do_request(options={})
        @api.get("/a", options)
      end
      
      it_should_behave_like "an http request"
    end
    
    describe ".post" do
      def do_request(options={})
        @api.post("/a", {}, options)
      end
      
      it_should_behave_like "an http request with a body"
    end
    
    describe ".put" do
      def do_request(options={})
        @api.put("/a", {}, options)
      end
      
      it_should_behave_like "an http request with a body"
    end
    
    describe '.delete' do
      def do_request(options={})
        @api.delete("/a", options)
      end
      
      it_should_behave_like "an http request"
    end
  end

  describe ".request_signature" do
    before(:each) do
      @api = Icontact::Api.new('username','password')
      Kernel.stub!(:rand).and_return(111)
      @mock_time = mock('Time', :getgm => 999999)
      Time.stub!(:now).and_return(@mock_time)
      Digest::SHA1.stub!(:hexdigest).and_return('api_signature')
    end
    
    it "should generate an API Signature" do
      Digest::SHA1.should_receive(:hexdigest).with('API_SECRETpasswordtimestamp/urlrandomGET').and_return('api_signature')
      @api.request_signature('get','timestamp''/url', 'random', '').should == "api_signature"
    end
  end
  
  describe ".apply_headers" do
    before(:each) do
      @request = mock('Request', :add_field=>true)
      @api = Icontact::Api.new('username','password')
    end
    
    def do_apply_headers
      @api.apply_headers(:get, @request, 'http://fakeurl.com')
    end
    
    it "should add an API_VERSION header to indicate we are using the 2.0 version of the API" do
      @request.should_receive(:add_field).with('API_VERSION', @api.class::API_VERSION)
      do_apply_headers
    end
    
    it "should add an ACCEPT header indicating we want a JSON object back" do
      @request.should_receive(:add_field).with('ACCEPT', 'application/json')
      do_apply_headers      
    end

    it "should add a Content-Type header indicating that passed data is JSON encoded" do
      @request.should_receive(:add_field).with('Content-Type', 'application/json')
      do_apply_headers      
    end
    
    it "should add an API_KEY header to verify that our application is authrorized to use the API" do
      @request.should_receive(:add_field).with('API_KEY', @api.class::API_KEY)
      do_apply_headers      
    end
    
    it "should add an API_USERNAME header to verify that our user is authorized to use the API" do
      @request.should_receive(:add_field).with('API_USERNAME', 'username')
      do_apply_headers      
    end
  
    it "should add an API_TIMESTAMP header to prevent old requests from being replayed" do
      @request.should_receive(:add_field).with('API_TIMESTAMP', 999999)
      do_apply_headers      
    end
    
    it "should add an API_NUMBER header" do
      @request.should_receive(:add_field).with('API_NUMBER', 111)
      do_apply_headers      
    end

    it "should add an API_SIGNATURE header to ensure this api request is valid" do
      @api.should_receive(:request_signature).and_return('api_signature')
      @request.should_receive(:add_field).with('API_SIGNATURE', 'api_signature')
      do_apply_headers
    end
  end
  
  describe "class methods" do
    it ".body_encoder should encode the data to be sent in JSON" do
      data = {:messageIds=>[1,2,3,4,5]}
      Icontact::Api::body_encoder(data).should == data.to_json
    end

    it ".parse_response should parse the JSON response into a hash" do
      body = {:messageIds=>[1,2,3,4,5]}.to_json
      Icontact::Api::parse_response(200, body).should == {"body"=>{"messageIds"=>[1, 2, 3, 4, 5]}, "code"=>200}
    end
  
    describe ".package_query_params" do
      # the "string".split('').sort trick is used because the string may come back in a different order each time because
      # it is generated from an unordered hash, this trick allows comparison 
      it "should package a hash into a query string according to the API requirements" do
        options = {:limit=>10, :offset=>10, :messageId=>[1,2,3,4], :createdAt=>Time.at(1234567890)}
        Icontact::Api::package_query_params(options).split('').sort.should == 
          "?limit=10&messageId=1,2,3,4&createdAt=2009-02-13T18:31:30-05:00&offset=10".split('').sort
      end
      
      it "should return nil if passed an empty hash" do
        Icontact::Api::package_query_params({}).should be_nil
      end
    end
    
  end
end
