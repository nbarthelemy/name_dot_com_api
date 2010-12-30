RAILS_ENV = 'test' if ENV['RAILS_ENV'] == 'development' || !ENV.key?('RAILS_ENV')

require 'rubygems'
require 'bundler/setup'
require 'spec'
require 'webmock/rspec'
require 'name_dot_com_api'

# http://kailuowang.blogspot.com/2010/08/testing-private-methods-in-rspec.html
def describe_internally *args, &block
  example = describe *args, &block
  klass = args[0]
  if klass.is_a? Class
    saved_private_instance_methods = klass.private_instance_methods
    example.before do
      klass.class_eval { public *saved_private_instance_methods }
    end
    example.after do
      klass.class_eval { private *saved_private_instance_methods }
    end
  end
end

Spec::Runner.configure do |config|
end