module Namdevel
  class Request

    def http(url, payload=nil, headers=nil)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        if(payload)
          request = Net::HTTP::Post.new(uri.request_uri, headers)
          request.body = payload.to_json
        else
          request = Net::HTTP::Get.new(uri.request_uri, headers)
        end
        response = http.request(request)
        return response.body
    end

    # @header_builder
    def buildheaders
      headers = {
        'content-type' => 'application/json',
        'app-id' => Namdevel::Constants::APP_ID,
        'app-version' => Namdevel::Constants::APP_VERSION,
        'os' => Namdevel::Constants::OS_NAME,
        'user-agent' =>  Namdevel::Constants::USER_AGENT
      }
      return headers
    end

  end
end