require File.dirname(__FILE__) + '/spec_helper'

describe NameDotComApi do

  describe "::Client" do

    before(:each) do
      @username = 'spec_user'
      @api_key = 'ds98fusdfjsdklfjk832934d9sa0d9auda8s7df8'
      @session_token = '34d9sa0d9auda8' # fake logged in

      @base_url = NameDotComApi.base_url

      @domain = 'example.com'
      @nameservers = [ 'ns1.name.com', 'ns2.name.com', 'ns3.name.com' ]
      @contact = {
        'type'         => [ 'registrant','administrative','technical','billing' ],
        'first_name'   => 'John',
        'last_name'    => 'Doe',
        'organization' => 'Name.com',
        'address_1'    => '125 Main St',
        'address_2'    => 'Suite 300',
        'city'         => 'Denver',
        'state'        => 'CO',
        'zip'          => '80230',
        'country'      => 'US',
        'phone'        => '+1.3035555555',
        'fax'          => '+1.3035555556',
        'email'        => 'john@example.net'
      }

      stub_request(:post, "#{@base_url}/login").
        to_return(successful_json_response(:session_token => @session_token))

      @client = NameDotComApi::Client.new(@username, @api_key)
    end

    def check_for_successful_response(response)
      response.result['code'].should == 100
      response.result['message'].should == "Command Successful"
    end

    def successful_json_response(body = {})
      { :status => 200, :body => { 
          :result => { :code => 100, :message => "Command Successful" } 
        }.merge(body).to_json }
    end

    it "can login" do
      @client.connection.logged_in?.should == true
    end

    it "can logoout" do
      stub_request(:get, "#{@base_url}/logout").to_return(successful_json_response)

      response = @client.logout
      check_for_successful_response(response)
    end

    it "can get hello response" do
      stub_request(:get, "#{@base_url}/hello").to_return(successful_json_response)

      response = @client.hello
      check_for_successful_response(response)
    end

    it "can get account information" do
      stub_request(:get, "#{@base_url}/account/get").
        to_return(successful_json_response(:username => @username))

      response = @client.get_account
      check_for_successful_response(response)
      response.username.should == @username
    end

    it "can list domains" do
      stub_request(:get, "#{@base_url}/domain/list/spec_user").
        to_return(successful_json_response(:domains => []))

      response = @client.list_domains
      check_for_successful_response(response)
    end

    it "can create a domain" do
      stub_request(:post, "#{@base_url}/domain/create").
        to_return(successful_json_response)

      response = @client.create_domain(@domain, 1, @nameservers, [ @contact ])
      check_for_successful_response(response)
    end

    it "can update nameservers for domain" do
      stub_request(:post, "#{@base_url}/domain/update_nameservers/#{@domain}").
        to_return(successful_json_response)

      response = @client.update_domain_nameservers(@domain, @nameservers)
      check_for_successful_response(response)
    end

    it "can update contacts for domain" do
      stub_request(:post, "#{@base_url}/domain/update_contacts/#{@domain}").
        to_return(successful_json_response)

      response = @client.update_domain_contacts(@domain, [ @contact ])
      check_for_successful_response(response)
    end

    it "can lock a domain" do
      stub_request(:get, "#{@base_url}/domain/lock/#{@domain}").
        to_return(successful_json_response)

      response = @client.lock_domain(@domain)
      check_for_successful_response(response)
    end

    it "can unlock a domain" do
      stub_request(:get, "#{@base_url}/domain/unlock/#{@domain}").
        to_return(successful_json_response)

      response = @client.unlock_domain(@domain)
      check_for_successful_response(response)
    end

    it "can list dns records" do
      stub_request(:get, "#{@base_url}/dns/list/#{@domain}").
        to_return(successful_json_response)

      response = @client.list_dns_records(@domain)
      check_for_successful_response(response)
    end

    it "can create a dns record" do
      stub_request(:post, "#{@base_url}/dns/create/#{@domain}").
        to_return(successful_json_response)

      response = @client.create_dns_record(@domain, 'www', 'A', '127.0.0.1', 300)
      check_for_successful_response(response)
    end

    it "can delete a dns record" do
      stub_request(:post, "#{@base_url}/dns/delete/#{@domain}").
        to_return(successful_json_response)

      response = @client.delete_dns_record(@domain, 1234)
      check_for_successful_response(response)
    end

    it "can check a domain" do
      stub_request(:post, "#{@base_url}/domain/power_check").
        to_return(successful_json_response)

      response = @client.check_domain('example', [ 'com' ])
      check_for_successful_response(response)
    end

    it "can create a domain" do
      stub_request(:post, "#{@base_url}/domain/create").
        to_return(successful_json_response)

      response = @client.create_domain(@domain, 1, @nameservers, [ @contact ])
      check_for_successful_response(response)
    end

    it "can get a domain" do
      stub_request(:get, "#{@base_url}/domain/get/#{@domain}").
        to_return(successful_json_response)

      response = @client.get_domain(@domain)
      check_for_successful_response(response)
    end

    it "can renew a domain" do
      stub_request(:post, "#{base_url}/domain/renew").
        to_return(successful_json_response)

      response = @client.renew_domain(@domain, 1)
      check_for_successful_response(response)
    end
  end
end
