require '../lib/Ovo'

ovo = Namdevel::Ovo.new()
# @Step 1 
# @getRefId
refId = ovo.login2FA('<phoneNumber>')
@refId = Namdevel::Response.new.getRefId(refId)
puts @refId

# @Step 2 
# @getupdateAccessToken
updateAccessToken = ovo.login2FAverify('<refId>','<otpCode>', '<phoneNumber>')
@updateAccessToken = Namdevel::Response.new.getupdateAccessToken(updateAccessToken)
puts @updateAccessToken

# @Step 3
# @getAuthToken
# @return eyJhbGciOiJSUzI1NiJ9.eyJleHBpcn......
AuthToken = ovo.loginSecurityCode('<securityCode>', '<updateAccessToken>')
@AuthToken = Namdevel::Response.new.geAuthToken(AuthToken)
puts @AuthToken