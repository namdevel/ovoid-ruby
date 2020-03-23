# Un-Official OVO API Wrapper for Ruby
Compliant with the March 19, 2020 OVO API update.

Reference
------------
- [@lintangtimur/ovoid](https://github.com/lintangtimur/ovoid) by [lintangtimur](https://github.com/lintangtimur)

Features
------------
- [x] login2FA
- [x] login2FAVerify
- [x] loginSecurityCode
- [x] verifyOVOMember
- [x] walletInquiry
- [x] getAccountNo
- [x] getAccountBalance
- [x] getAccountPoint
- [x] getBankList
- [x] getNotification
- [x] getLastTransfer
- [x] getHistory
- [x] generateSignature `private unpublished` (for transfer more than 2 times)
- [x] transferOvo
- [x] transferBank

# Usage
```ruby
require '../lib/Ovo'
```
##### Step 1
```ruby
ovo = Namdevel::Ovo.new()

# @Step 1 
# @getRefId
refId = ovo.login2FA('<phoneNumber>')
@refId = Namdevel::Response.new.getRefId(refId)
puts @refId
```
##### Step 2
```ruby
ovo = Namdevel::Ovo.new()

# @Step 2 
# @getupdateAccessToken
updateAccessToken = ovo.login2FAverify('<refId>','<otpCode>', '<phoneNumber>')
@updateAccessToken = Namdevel::Response.new.getupdateAccessToken(updateAccessToken)
puts @updateAccessToken
```
##### Step 3
```ruby
ovo = Namdevel::Ovo.new()

# @Step 3
# @getAuthToken
# @return eyJhbGciOiJSUzI1NiJ9.eyJleHBpcn......
AuthToken = ovo.loginSecurityCode('<securityCode>', '<updateAccessToken>')
@AuthToken = Namdevel::Response.new.geAuthToken(AuthToken)
puts @AuthToken
```
# Example
```ruby
require '../lib/Ovo'

# @see getAuthToken.rb to get Authorization Token
# @1 = page , @10 = max result
# @return json
authToken = 'eyJhbGciOiJSUzI1NiJ9.eyJleHBpcn......'
ovo = Namdevel::Ovo.new(authToken)
puts ovo.getHistory('1', '10')
```
More see on `example`.

License
------------

This open-source software is distributed under the MIT License. See LICENSE

Contributing
------------

All kinds of contributions are welcome - code, tests, documentation, bug reports, new features, etc...

* Send feedbacks.
* Submit bug reports.
* Write/Edit the documents.
* Fix bugs or add new features.
