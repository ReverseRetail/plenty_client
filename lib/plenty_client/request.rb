require 'curl'
module PlentyClient
  module Request
    def request(http_method, path, params = {})
      return false if http_method.nil? || path.nil?
      return false unless %w(post put patch delete get).include?(http_method.to_s)

      login if PlentyClient::Config.access_token.nil?
      start_time = Time.now
      response = perform(http_method, path, params)
      body = parse_body(response, http_method, path, params)
      if PlentyClient::Config.log
        log_output(http_method, base_url(path), params, time_diff_ms(start_time, Time.now))
      end
      body
    end

    def post(path, body = {})
      request(:post, path, body)
    end

    def put(path, body = {})
      request(:put, path, body)
    end

    def patch(path, body = {})
      request(:patch, path, body)
    end

    def delete(path, body = {})
      request(:delete, path, body)
    end

    def get(path, params = {}, &block)
      page = 1
      rval_array = []
      if block_given?
        loop do
          response = request(:get, path, params.merge(page: page))
          yield response['entries'] if block_given?
          page += 1
          break if response['isLastPage'] == true
        end
      else
        response = request(:get, path, params.merge(page: page))
        rval_array << rval
      end
      rval_array.flatten
    end

    private

    def login
      response = perform(:post, "/login?username=#{PlentyClient::Config.api_user}" \
                                "&password=#{PlentyClient::Config.api_password}")
      result = parse_body(response, :post, 'login')
      PlentyClient::Config.access_token  = result['accessToken']
      PlentyClient::Config.refresh_token = result['refreshToken']
    end

    def perform(http_method, path, params = {})
      case http_method.to_s.downcase
      when 'get'
        Curl.get(base_url(path), params) do |curl|
          curl_options(curl)
        end
      when 'post'
        Curl.post(base_url(path), params) do |curl|
          curl_options(curl)
        end
      when 'put'
        Curl.put(base_url(path), params) do |curl|
          curl_options(curl)
        end
      when 'delete'
        Curl.delete(base_url(path), params) do |curl|
          curl_options(curl)
        end
      when 'patch'
        Curl.patch(base_url(path), params) do |curl|
          curl_options(curl)
        end
      end
    end

    def curl_options(curl)
      curl.headers['Content-type'] = 'application/json'
      unless PlentyClient::Config.access_token.nil?
        curl.headers['Authorization'] = "Bearer #{PlentyClient::Config.access_token}"
      end
      curl.headers['Accept'] = 'application/x.plentymarkets.v1+json'
      curl
    end

    def base_url(path)
      uri = URI(PlentyClient::Config.site_url)
      url = "#{uri.scheme}://#{uri.host}/rest"
      url += path.start_with?('/') ? path : "/#{path}"
      url
    end

    def login_required?(path)
      return false if defined?(Rails) && Rails.env == 'testing'
      return true unless path.include?('login')
      false
    end

    def parse_body(response, http_method, rest_path, params = {})
      result = JSON.parse(response.body)
      raise InvalidResponseException.new(http_method, rest_path, params) if result.nil?
      result
    end

    def log_output(http_method, path, params, duration)
      puts [Time.now, "#{duration} ms", http_method.upcase, path, params].join(' # ')
    end

    def time_diff_ms(start, finish)
      ((finish - start) * 1000.0).round(2)
    end
  end
end

class InvalidResponseException < StandardError
  def initialize(http_method, rest_path, params)
    super("The response was null. http_Method: #{http_method}, Path: #{rest_path}, options: #{params}")
  end
end