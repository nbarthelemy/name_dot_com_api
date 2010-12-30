require File.dirname(__FILE__) + '/spec_helper'

describe NameDotComApi do

  describe "#base_url" do

    it "returns test url" do
      NameDotComApi.base_url(true).should == 'https://api.dev.name.com/api'
    end

    it "returns production url" do
      NameDotComApi.base_url.should == 'https://api.name.com/api'
      NameDotComApi.base_url(false).should == 'https://api.name.com/api'
    end

  end

end