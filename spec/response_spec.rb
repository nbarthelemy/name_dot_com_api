require File.dirname(__FILE__) + '/spec_helper'

describe NameDotComApi do

  describe "::Response" do

    before(:each) do
      @response = NameDotComApi::Response.new("{\"a\":1,\"b\":2,\"c\":[1,2]}")
    end

    it "parses a json object" do
      @response['a'].should == 1
      @response['b'].should == 2
      @response['c'].should == [1,2]
    end

    it "allows top level hash keys to be called as methods" do
      @response.a.should == 1
      @response.b.should == 2
      @response.c.should == [1,2]
    end

  end

end