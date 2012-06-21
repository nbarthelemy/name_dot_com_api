module NameDotComApi

  class Client

    attr_reader :connection

    def initialize(username, api_token, test_mode = false)
      @connection ||= Connection.new
      @connection.test_mode = test_mode
      login username, api_token
    end

    # response = client.login(username, api_token)
    def login(username, api_token)
      raise "You are already logged in" if @connection.logged_in?

      @connection.username ||= username
      @connection.api_token ||= api_token

      connection.post '/login', { 
        :username => @connection.username, :api_token => @connection.api_token
      }
    end

    # response = client.logout
    def logout
      connection.get '/logout'
    end

    # response = client.hello
    def hello
      connection.get '/hello'
    end

    # response = client.get_account
    def get_account
      connection.get '/account/get'
    end

    # response = client.list_domains
    def list_domains
      connection.get "/domain/list/#{connection.username}"
    end

    # response = client.update_domain_nameservers('example.com', [
    #   'ns1.name.com', 'ns2.name.com', 'ns3.name.com'
    # ])
    def update_domain_nameservers(domain, nameservers = {})
      connection.post "/domain/update_nameservers/#{domain}", { :nameservers => nameservers }
    end

    # response = client.update_domain_contacts('mynewdomain.com', [
    #   { 'type' => [ 'registrant','administrative','technical','billing' ],
    #     'first_name'   => 'John',
    #     'last_name'    => 'Doe',
    #     'organization' => 'Name.com',
    #     'address_1'    => '125 Main St',
    #     'address_2'    => 'Suite 300',
    #     'city'         => 'Denver',
    #     'state'        => 'CO',
    #     'zip'          => '80230',
    #     'country'      => 'US',
    #     'phone'        => '+1.3035555555',
    #     'fax'          => '+1.3035555556',
    #     'email'        => 'john@example.net'
    #   }
    # ])
    def update_domain_contacts(domain, contacts = [])
      connection.post "/domain/update_contacts/#{domain}", { :contacts => contacts }
    end

    # response = client.lock_domain('example.com')
    def lock_domain(domain)
      connection.get "/domain/lock/#{domain}"
    end

    # response = client.unlock_domain('example.com')
    def unlock_domain(domain)
      connection.get "/domain/unlock/#{domain}"
    end

    # response = client.list_dns_records('example.com')
    def list_dns_records(domain)
      connection.get "/dns/list/#{domain}"
    end

    # response = client.create_dns_record('example.com', 'www', 'A', '127.0.0.1', 300)
    # response = client.create_dns_record('example.com', 'mail', 'MX', 'mx3.name.com', 300, 10)
    def create_dns_record(domain, hostname, type, content, ttl, priority = nil)
      body = {
        'hostname' => hostname,
        'type'     => type,
        'content'  => content,
        'ttl'      => ttl
      }
      body.update!(:priority => priority) if priority
      connection.post "/dns/create/#{domain}", body
    end
    alias :add_dns_record :create_dns_record

    # response = client.delete_dns_record('example.com', 1234)
    def delete_dns_record(domain, record_id)
      connection.post "/dns/delete/#{domain}", { :record_id => record_id }
    end
    alias :remove_dns_record :delete_dns_record

    # response = client.check_domain('example')
    # response = client.check_domain('example', [ 'com', 'net', 'org' ], [ 'availability','suggested' ])
    def check_domain(keyword, tlds = nil, services = nil)
      connection.post '/domain/power_check', {
        'keyword'  => keyword,
        'tlds'     => tlds || [ 'com' ], # ,'net','org','info','us','biz','tel' ],
        'services' => services || [ 'availability' ] # ,'suggested' ]
      }
    end

    # ns = [ 'ns1.name.com', 'ns2.name.com', 'ns3.name.com' ]
    # response = client.create_domain('example.com', 1, ns, [
    #   { 'type' => [ 'registrant','administrative','technical','billing' ],
    #     'first_name'   => 'John',
    #     'last_name'    => 'Doe',
    #     'organization' => 'Name.com',
    #     'address_1'    => '125 Main St',
    #     'address_2'    => 'Suite 300',
    #     'city'         => 'Denver',
    #     'state'        => 'CO',
    #     'zip'          => '80230',
    #     'country'      => 'US',
    #     'phone'        => '+1.3035555555',
    #     'fax'          => '+1.3035555556',
    #     'email'        => 'john@example.net'
    #   }
    # ])
    def create_domain(domain, period = 1, nameservers = nil, contacts = nil)
      options = {
        'domain_name' => domain,
        'period'      => period,
        'nameservers' => nameservers,
        'contacts'    => contacts,
        'username'    => connection.username
      }
      options.delete('nameservers') unless nameservers
      options.delete('contacts') unless contacts
      connection.post '/domain/create', options
    end


    def renew_domain(domain, period = 1)
      options = {
        'domain_name' => domain,
        'period'      => period,
      }
      connection.post '/domain/create', options
    end


    # response = client.get_domain('example.com')
    def get_domain(domain)
      connection.get "/domain/get/#{domain}"
    end

  end

end
