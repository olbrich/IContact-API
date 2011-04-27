require 'net/http'
require 'net/https'
require 'json'

class Icontact
  class Api
    VERSION = "0.3"
    API_VERSION = "2.2"
    URL = 'https://app.icontact.com/icp'
    API_KEY = "API_KEY"
    attr_accessor :username
    attr_accessor :password
    attr_accessor :app_id
    attr_accessor :url
    attr_accessor :api_version
  
    def initialize(username=nil, password=nil)
      self.username = username
      self.password = password
      self.url = URL
      self.app_id = API_KEY
      self.api_version = API_VERSION
    end
    
    # Package up any options into a query string and format it properly for the server
    # arrays become comma separated lists and Times are expressed as iso8601
    def self.package_query_params(params={})
      return nil if params.nil? || params.empty?
      massaged_params = params.map do |key, value|
        case value
          when Array:
            "#{key}=#{value.join(',')}"
          when Time:
            "#{key}=#{value.strftime("%Y-%m-%dT%H:%M:%S")}#{"%+0.2d:00" % (value.gmtoff / 3600)}"
          else
            "#{key}=#{value}"
        end
      end
      "?#{massaged_params.join('&')}"
    end
  
    # override this to use a different encoding method for sending data (like xml)
    def self.body_encoder(data)
      data.to_json
    end
  
    # override this method to use a different response parser (like REXML for an xml response)
    # when the response is not actually a JSON object an exception is thrown and the raw response is returned in the body instead.
    def self.parse_response(code, response)
      {'code'=>code, 'body' => (JSON.parse(response) rescue response)}
    end
  
    # populate headers required by the icontact server on each request for authentication
    # Accept and Content-Type are set to application/json to use JSON objects for the 
    # data exchange.  Also accepts text/xml for either, but then you have to deal with XML encoding and decoding
    # manually
    def apply_headers(req)
      req.add_field('API-Version', self.api_version)
      req.add_field('accept','application/json')
      req.add_field('Content-Type','application/json')
      req.add_field('API-Appid', self.app_id)
      req.add_field('API-Username', self.username)
      req.add_field('API-Password', self.password)
      return req
    end
  
    # dynamically create methods for get and delete.  These methods do not require a body to be sent
    [:get, :delete].each do |meth|
      define_method(meth) do |url, *options|
        request(meth, url, nil, options)
      end
    end

    # dynamically create methods for get and delete.  These methods require a body to be sent  
    [:post, :put].each do |meth|
      define_method(meth) do |url, data, *options|
        request(meth, url, data, options)
      end
    end
  
    # Actually make the get, put, post, or delete request
    def request(kind, url, data, options)
      # options passed as optional parameter show up as an array
      options = options.first if options.kind_of? Array
      query_options = self.class.package_query_params(options)
      full_url = URI.parse("#{self.url}#{url}#{query_options}")
    
      # create an object of the class required to process this method
      klass = Object.module_eval("::Net::HTTP::#{kind.to_s.capitalize}", __FILE__, __LINE__)
      request = klass.new([full_url.path, full_url.query].compact.join('?'))
      request = apply_headers(request)
      # take passed data and encode it
      request.body = self.class.body_encoder(data) if data
    
      http = Net::HTTP.new(full_url.host, full_url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = http.start do |web|
        web.request(request)
      end
      return self.class.parse_response(response.code, response.body)
    end
  end
end