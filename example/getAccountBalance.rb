require '../lib/Ovo'

# @see getAuthToken.rb to get Authorization Token
# @return json
authToken = 'eyJhbGciOiJSUzI1NiJ9.eyJleHBpcn......'
ovo = Namdevel::Ovo.new(authToken)
puts ovo.getAccountBalance