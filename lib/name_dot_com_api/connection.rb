require 'cgi'
require 'net/https'
require 'uri'
require 'json'

module NameDotComApi

  class ConnectionError < StandardError
    attr_reader :response

    def initialize(response, message = nil)
      @response = response
      @message  = message
    end

    def to_s
      "Failed with #{response.code} #{response.message if response.respond_to?(:message)}"
    end
  end

  class Connection
    HTTP_FORMAT_HEADER_NAMES = {
      :get    => 'Accept',
      :post   => 'Content-Type'
    }

    JSON_MIME_TYPE = 'text/json; charset=utf-8'

    def initialize(test_mode = false)
      @headers ||= {}
      @cookies ||= {}
      @test_mode = test_mode
    end

    attr_accessor :username, :api_token, :session_token
    attr_accessor :url, :cookies, :timeout, :test_mode

    def logged_in?; !!session_token; end

    # Set URI for remote service.
    def url=(url)
      @url = url.is_a?(URI) ? url : URI.parse(url)
    end

    # Creates new Net::HTTP instance for communication with remote service and resources.
    def http
      http              = Net::HTTP.new(url.host, url.port)
      http.use_ssl      = url.is_a?(URI::HTTPS)
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE if http.use_ssl
      http.read_timeout = timeout || 60 # Net::HTTP default 60 seconds
      http.set_debug_output $stderr if test_mode
      http
    end

    def get(path, params = {}); request(:get, path, params); end
    def post(path, params = {}); request(:post, path, params); end

    def logger
      defined?(ActiveRecord) ? ActiveRecord::Base.logger : nil
    end

  private

    # Makes request to remote service.  # Be sure to handle Timeout::Error
    def request(method, path, params = {})
      # ensure the user is logged in or logging in
      raise "You must first login" unless path =~ /^\/login/ || logged_in?

      self.url = "#{NameDotComApi.base_url(test_mode)}#{path}"

      logger.info "#{method.to_s.upcase} #{url.to_s}" if logger
      logger.info "with body: #{params.inspect}" if logger

      result = case method
        when :get then http.send(method, url.to_s, build_request_headers(method))
        when :post then http.send(method, url.to_s, params.to_json, build_request_headers(method))
      end

      logger.info "--> %d %s (%d)" % [ result.code, result.message, result.body ? result.body.length : 0 ] if logger

      handle_response(result)
    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    end

    # Builds headers for request to remote service.
    def build_request_headers(http_method = nil)
      headers = {}

      if session_token
        logger.info "SessionToken: #{session_token}" if logger
        headers['Api-Session-Token'] = session_token
      end

      if username && api_token
        logger.info "Username: #{username}" if logger
        headers['Api-Username'] = username

        logger.info "SessionToken: #{api_token}" if logger
        headers['Api-Token'] = api_token
      end

      http_format_header(http_method).update(cookie_header).update(headers)
    end

    # Builds the cookie header according to what's stored in @cookies
    # Encodes correctly for cookies, e.g. key1=value1; key2=value2
    def cookie_header
      unless cookies.nil? || cookies.empty?
        pairs = @cookies.inject([]) do |a, p|
          a << "#{CGI::escape(p[0].to_s)}=#{CGI::escape(p[1].to_s)}"; a
        end
        { 'Cookie' => pairs.join('; ') }
      else
        {}
      end
    end

    def http_format_header(http_method)
      { HTTP_FORMAT_HEADER_NAMES[http_method] => JSON_MIME_TYPE }
    end

    # Handles response and error codes from remote service.
    def handle_response(response)
      case response.code.to_i
      when 200
        response = ::NameDotComApi::Response.new(response.body)
        unless response['session_token'].nil?
          self.session_token = response['session_token']
        end
        response
      when 301, 302
        raise ConnectionError.new(response, "Redirection response code: #{response.code}")
      else
        raise ConnectionError.new(response, "Connection response code: #{response.code}")
      end
    end

  end

end