# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'raudi/version'

Gem::Specification.new do |s|
  s.name        = "raudi"
  s.version     = Raudi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = %w(James Lawrence)
  s.email       = %w(james@kukee.co.uk)

  s.summary = "Raudi aims to be a simple to use audio synthesis library for use in ruby"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) } # Stolen from github gem, uses git to list files, very nice!
  s.require_paths = %w(lib)

  s.add_dependency "ffi-portaudio", "~>0.1"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~>1.3.1"
end