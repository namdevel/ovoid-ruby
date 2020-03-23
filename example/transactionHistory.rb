require '../lib/Ovo'

# @see getAuthToken.rb to get Authorization Token
# @1 = page , @10 = max result
# @return json
authToken = 'eyJhbGciOiJSUzI1NiJ9.eyJleHBpcn......'
ovo = Namdevel::Ovo.new(authToken)
puts ovo.getHistory('1', '10')