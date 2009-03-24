require 'rubygems'
require 'net/http'
require 'digest'
require 'json'

class Icontact
  class Api
    VERSION = "0.1"
    API_VERSION = "2.0"
    DOMAIN = 'http://app.icontact.com/icp'
    API_KEY = "API_KEY"
    API_SECRET = "API_SECRET"
    attr_accessor :username
    attr_accessor :password
    attr_accessor :key
    attr_accessor :secret
    attr_accessor :domain
  
    def initialize(username, password)
      self.username = username
      self.password = password
      self.domain = DOMAIN
      self.key = API_KEY
      self.secret = API_SECRET
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
  
    def request_signature(method, timestamp, random, url)
      Digest::SHA1.hexdigest("#{secret}#{password}#{timestamp}#{random}#{method.to_s.upcase}#{url}")
    end
  
    # populate headers required by the icontact server on each request for authentication
    # Accept and Content-Type are set to application/json to use JSON objects for the 
    # data exchange.  Also accepts text/xml for either, but then you have to deal with XML encoding and decoding
    # manually
    def apply_headers(method, req, url)
      timestamp = Time.now.getgm.to_i
      random = Kernel.rand(999999)
      req.add_field('API_VERSION', API_VERSION)
      req.add_field('ACCEPT','application/json')
      req.add_field('Content-Type','application/json')
      req.add_field('API_KEY', self.key)
      req.add_field('API_USERNAME', self.username)
      req.add_field('API_TIMESTAMP', timestamp)
      req.add_field('API_NUMBER', random)
      req.add_field('API_SIGNATURE', request_signature(method, timestamp, random, url))
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
      full_url = URI.parse("#{self.domain}#{url}#{query_options}")
    
      # create an object of the class required to process this method
      klass = Object.module_eval("::Net::HTTP::#{kind.to_s.capitalize}", __FILE__, __LINE__)
      request = klass.new([full_url.path, full_url.query].compact.join('?'))
      request = apply_headers(kind, request, full_url)
    
      # take passed data and encode it
      request.body = self.class.body_encoder(data) if data
    
      Net::HTTP.start(full_url.host, full_url.port) do |http|
        response = http.request(request)
        return self.class.parse_response(response.code, response.body)
      end  
    end
  end
end