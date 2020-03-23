require 'net/http'
require 'uri'
require 'json'
require 'time'
require 'securerandom'
require 'digest/sha1'

require_relative 'Constants'
require_relative 'Request'
require_relative 'Response'

module Namdevel
  class Ovo

    # @constructor
    def initialize(token=nil)
      @Request = Namdevel::Request.new
      @Response = Namdevel::Response.new
      @Headers = @Request.buildheaders
      @auth_token = token
      @device = Namdevel::Constants::DEVICE_ID
      #@device = self.generateDeviceId

      if (@auth_token)
        @Headers.store('authorization', @auth_token)
      end
    end

    # @generateDeviceId
    def generateDeviceId
      return SecureRandom.uuid.upcase
    end

    # @login2FA
    def login2FA(phoneNumber)
      payload = {
        'mobile' => phoneNumber,
        'deviceId' => @device
      }
      return @Request.http(Namdevel::Constants::API + '/v2.0/api/auth/customer/login2FA', payload, @Headers)
    end

    # @login2FAverify
    def login2FAverify(refId, otp, phoneNumber)
      payload = {
        'refId' => refId,
        'verificationCode' => otp,
        'mobile' => phoneNumber,
        'osName' => Namdevel::Constants::OS_NAME,
        'osVersion' => Namdevel::Constants::OS_VERSION,
        'deviceId' => @device,
        'appVersion' => Namdevel::Constants::APP_VERSION,
        'pushNotificationId' => Namdevel::Constants::PUSH_NOTIFICATION
      }
      return @Request.http(Namdevel::Constants::API + '/v2.0/api/auth/customer/login2FA/verify', payload, @Headers)
    end

    # @loginSecurityCode
    def loginSecurityCode(securityCode, updateAccessToken)
      payload = {
        'deviceUnixtime' => Time.now.to_time.to_i,
        'securityCode' => securityCode,
        'updateAccessToken' => updateAccessToken
      }
      return @Request.http(Namdevel::Constants::API + '/v2.0/api/auth/customer/loginSecurityCode/verify', payload, @Headers)
    end

    # @logout
    def logout
      return @Request.http(Namdevel::Constants::API + '/v1.0/api/auth/customer/logout', nil, @Headers)
    end

    # @verifyOVOMember
    def verifyOVOMember(phoneNumber, amount=10000)
      @amount = amount < 10000 ? '10000' : amount
      payload = {
        'mobile' => phoneNumber,
        'amount' => @amount
      }
      return @Request.http(Namdevel::Constants::API + '/v1.1/api/auth/customer/isOVO', payload, @Headers)
    end

    # @walletInquiry
    def walletInquiry
      return @Request.http(Namdevel::Constants::API + '/wallet/inquiry', nil, @Headers)
    end

    # @getNotification
    def getNotification
      return @Request.http(Namdevel::Constants::API + '/v1.0/notification/status/all', nil, @Headers)
    end

    # @getLastTransfer
    def getLastTransfer
      return @Request.http(Namdevel::Constants::API + '/wallet/transaction/last?limit=5&transaction_type=TRANSFER&transaction_type=EXTERNAL%20TRANSFER', nil, @Headers)
    end

    # @getAccountNo
    def getAccountNo
      json = JSON.parse(self.walletInquiry)
      return json['data']['001']['card_no']
    end

    # @getAccountBalance
    def getAccountBalance
      json = JSON.parse(self.walletInquiry)
      return json['data']['001']['card_balance']
    end

    # @getAccountPoint
    def getAccountPoint
      json = JSON.parse(self.walletInquiry)
      return json['data']['600']['card_balance']
    end

    # @getBankList
    def getBankList
      return @Request.http(Namdevel::Constants::API + '/v1.0/reference/master/ref_bank', nil, @Headers)
    end

    # @getHistory Transactions
    def getHistory(page='1', limit='10')
      return @Request.http(Namdevel::Constants::API + '/wallet/v2/transaction?page=' + page + '&limit=' + limit, nil, @Headers)
    end

    # @generateTrxId
    def generateTrxId(amount)
      payload = {
        'amount' => amount,
        'actionMark' => Namdevel::Constants::ACTION_MARK
      }
      return @Request.http(Namdevel::Constants::API + '/v1.0/api/auth/customer/genTrxId', payload, @Headers)
    end

    # @generateSignature
    def generateSignature()
      # private code unpublished
      return Digest::SHA1.hexdigest(Time.now.to_time.to_s)
    end

    # @unlockAndValidateTrxId
    def unlockAndValidateTrxId(trxId, amount, securityCode)
      payload = {
        'trxId' => trxId,
        'signature' => self.generateSignature(),
        'securityCode' => securityCode
      }
      return @Request.http(Namdevel::Constants::API + '/v1.0/api/auth/customer/unlockAndValidateTrxId', payload, @Headers)
    end

    # @transferOvo
    def transferOvo(amount, destination, securityCode, message="")
      prepare = self.verifyOVOMember(destination, amount.to_i)
      @prepare = JSON.parse(prepare)
      if(@prepare['fullName'])
        trxId = @Response.getTrxId(self.generateTrxId(amount))
        payload = {
          'amount' => amount,
          'trxId' => trxId,
          'to' => destination,
          'message' => message
        }
        transferOvo = @Request.http(Namdevel::Constants::API + '/v1.0/api/customers/transfer', payload, @Headers)
        if(transferOvo.include? "sorry unable to handle your request")
          unlockTrxId = self.unlockAndValidateTrxId(trxId, amount, securityCode)
          @unlockTrxId = JSON.parse(unlockTrxId)
          if(@unlockTrxId['isAuthorized'])
            return @Request.http(Namdevel::Constants::API + '/v1.0/api/customers/transfer', payload, @Headers)
          else
            return unlockTrxId
          end
        else
          return transferOvo
        end
      else
        return prepare
      end
    end

    # @transferBankPrepare
    def transferBankPrepare(bankCode, bankNumber, amount, message="")
      payload = {
        'bankCode' => bankCode,
        'accountNo' => bankNumber,
        'amount' => amount,
        'message' => message
      }
      return @Request.http(Namdevel::Constants::API + '/transfer/inquiry', payload, @Headers)
    end

    # @transferBankExecute
    def transferBankExecute(amount, bankName, bankCode, bankAccountNumber, bankAccountName, trxId, notes="")
      payload = {
        'accountNo' => self.getAccountNo,
        'amount' => amount,
        'bankName' => bankName,
        'bankCode' => bankCode,
        'accountNoDestination' => bankAccountNumber,
        'accountName' => bankAccountName,
        'transactionId' => trxId,
        'notes' => notes
      }
      return @Request.http(Namdevel::Constants::API + '/transfer/direct', payload, @Headers)
    end

    # @transferBank
    def transferBank(amount, bankCode, bankNumber, securityCode, notes="")
      prepare = self.transferBankPrepare(bankCode, bankNumber, amount)
      @prepare = JSON.parse(prepare)
      if(@prepare['accountName'])
        trxId = @Response.getTrxId(self.generateTrxId(amount))
        transferBank = self.transferBankExecute(@prepare['baseAmount'], @prepare['bankName'], @prepare['bankCode'], @prepare['accountNo'], @prepare['accountName'], trxId, notes)
        if(transferBank.include? "sorry unable to handle your request")
          unlockTrxId = self.unlockAndValidateTrxId(trxId, amount, securityCode)
          @unlockTrxId = JSON.parse(unlockTrxId)
          if(@unlockTrxId['isAuthorized'])
            return self.transferBankExecute(@prepare['baseAmount'], @prepare['bankName'], @prepare['bankCode'], @prepare['accountNo'], @prepare['accountName'], trxId, notes)
          else
            return unlockTrxId
          end
        else
          return transferBank
        end
      else
        return prepare
      end
    end

  end
end