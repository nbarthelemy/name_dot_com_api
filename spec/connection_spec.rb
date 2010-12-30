require File.dirname(__FILE__) + '/spec_helper'

# test the private methods; see spec/spec_helper.rb
describe_internally NameDotComApi::Connection do

  before(:each) do
    @connection = NameDotComApi::Connection.new
    @connection.username = 'spec_user'
    @connection.api_token = 'ds98fusdfjsdklfjk832934d9sa0d9auda8s7df8'
    @connection.session_token = '34d9sa0d9auda8' # fake logged in

    @test_path = '/hello'
    @test_url = "#{NameDotComApi.base_url(@connection.test_mode)}#{@test_path}"
  end

  it "can represent both login states" do
    @connection.logged_in?.should == true

    @connection.session_token = nil
    @connection.logged_in?.should == false
  end

  it "can build cookie headers" do
    # no cookies
    @connection.cookie_header.should == {}

    # cookies
    @connection.cookies = { 'test' => 'cookie' }
    @connection.cookie_header.should == { 'Cookie' => 'test=cookie' }
  end

  it "can retrieve the correct http format header (get/post)" do
    @connection.http_format_header(:get).should == { "Accept" => "text/json; charset=utf-8" }
    @connection.http_format_header(:post).should == { "Content-Type" => "text/json; charset=utf-8" }
  end

  it "can build request headers (get/post)" do
    # get
    @connection.build_request_headers(:get).should == {
      "Api-Username"      => @connection.username,
      "Api-Token"         => @connection.api_token,
      "Api-Session-Token" => @connection.session_token,
      "Accept"            => NameDotComApi::Connection::JSON_MIME_TYPE
    }

    # post
    @connection.build_request_headers(:post).should == {
      "Api-Username"      => @connection.username,
      "Api-Token"         => @connection.api_token,
      "Api-Session-Token" => @connection.session_token,
      "Content-Type"      => NameDotComApi::Connection::JSON_MIME_TYPE
    }
  end

  it "can make a request (get/post)" do
    # get
    stub_request(:get, @test_url).to_return(:status => 200, :body => "{}")
    @connection.request(:get, @test_path).should == {}

    # post
    stub_request(:post, @test_url).with(:body => "{}").to_return(:status => 200, :body => '{}')
    @connection.request(:post, @test_path).should == {}
  end

  it "can handle a 200 response" do
    @mock = mock('Net::HTTPResponse')
    @mock.stub(:code => '200', :message => "OK", :content_type => "text/json", :body => '{}')
    @connection.handle_response(@mock).should == {}
  end

  it "can handle a 30X response" do
    @mock = mock('Net::HTTPResponse')
    @mock.stub(:code => '301', :message => "PERMANENTLY MOVED", :content_type => "text/json", :body => '')
    lambda{ @connection.handle_response(@mock) }.should raise_error(NameDotComApi::ConnectionError)

    @mock = mock('Net::HTTPResponse')
    @mock.stub(:code => '302', :message => "TEMPORARILY MOVED", :content_type => "text/json", :body => '')
    lambda{ @connection.handle_response(@mock) }.should raise_error(NameDotComApi::ConnectionError)
  end

  it "can handle any other response" do
    @mock = mock('Net::HTTPResponse')
    @mock.stub(:code => '400', :message => "NOT FOUND", :content_type => "text/json", :body => '')
    lambda{ @connection.handle_response(@mock) }.should raise_error(NameDotComApi::ConnectionError)
  end

end

describe NameDotComApi::Connection do

  before(:each) do
    @connection = NameDotComApi::Connection.new
    @connection.username = 'spec_user'
    @connection.api_token = 'ds98fusdfjsdklfjk832934d9sa0d9auda8s7df8'
    @connection.session_token = '34d9sa0d9auda8' # fake logged in

    @test_path = '/hello'
    @test_url = "#{NameDotComApi.base_url(@connection.test_mode)}#{@test_path}"
  end

  it "can set test mode" do
    @connection.test_mode = true
    @connection.test_mode.should == true
    @connection.test_mode = false
    @connection.test_mode.should == false
  end

  it "can create an http object" do
    @connection.url = @test_url
    @connection.http.is_a?(Net::HTTP).should == true
  end

  it "can make a get request" do
    stub_request(:get, @test_url).to_return(:status => 200, :body => "{}")
    @connection.get(@test_path).should == {}
  end

  it "can make a post request" do
    stub_request(:post, @test_url).with(:body => "{}").to_return(:status => 200, :body => '{}')
    @connection.post(@test_path).should == {}
  end

end