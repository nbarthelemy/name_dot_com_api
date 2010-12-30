# client = NameDotComApi::Client.new('< username >','< api_token >', < test mode >)
# response = client.check_domain('< domain_name >')

require 'name_dot_com_api/client'
require 'name_dot_com_api/connection'
require 'name_dot_com_api/response'

module NameDotComApi

  TEST_API_HOST = 'https://api.dev.name.com/api'
  PRODUCTION_API_HOST = 'https://api.name.com/api'

  def self.base_url(test_mode = false)
    test_mode ? TEST_API_HOST : PRODUCTION_API_HOST
  end

end