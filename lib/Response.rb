module Namdevel
  class Response

    #getMessage
    def getMessage(response)
      json = JSON.parse(response)
      return json['message']
    end

     #getRefId
    def getRefId(response)
      json = JSON.parse(response)
      refId = json['refId']
      if(refId)
        return json['refId']
      else
        return getMessage(response)
      end
    end

    #getupdateAccessToken
    def getupdateAccessToken(response)
      json = JSON.parse(response)
      updateAccessToken = json['updateAccessToken']
      if(updateAccessToken)
        return json['updateAccessToken']
      else
        return getMessage(response)
      end
    end

    #getToken
    def geAuthToken(response)
      json = JSON.parse(response)
      token = json['token']
      if(token)
        return json['token']
      else
        return getMessage(response)
      end
    end

    #getTrxId
    def getTrxId(response)
      json = JSON.parse(response)
      token = json['trxId']
      if(token)
        return json['trxId']
      else
        return getMessage(response)
      end
    end

  end
end