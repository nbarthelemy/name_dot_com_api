# -*- encoding: utf-8 -*-
require File.expand_path("../lib/name_dot_com_api/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "name_dot_com_api"
  s.version     = NameDotComApi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Nicholas Barthelemy' ]
  s.email       = [ 'nicholas.barthelemy@gmail.com' ]
  s.homepage    = "https://github.com/nbarthelemy/name_dot_com_api"
  s.summary     = "An easy to use unterface for the name.com api"
  s.description = "This gem allows you to interact with the name.com api via ruby."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "name_dot_com_api"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
