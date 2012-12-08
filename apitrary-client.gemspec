# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "apitrary-client"
  s.version     = "0.4.0"
  s.date        = '2012-11-23'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sebastian Spier"]
  s.email       = ["sebastian.spier@apitrary.com"]
  s.homepage    = "http://apitrary.net"
  s.summary     = "A client for your apitrary API."
  s.description = "A client for your apitrary API. Have fun :)"

  s.add_dependency 'httparty'
  s.add_dependency 'json'

  s.add_development_dependency "rspec"

  s.post_install_message = "Backend-as-a-Service at it's best with apitrary :)"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
