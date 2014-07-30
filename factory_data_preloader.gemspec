# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{factory_data_preloader}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kyle J. Ginavan"]
  s.date = %q{2009-07-09}
  s.email = %q{kylejginavan@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
 
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
 
  s.has_rdoc = true
  s.homepage = %q{http://github.com/kylejginavan/factory_data_preloader}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A library for preloading test data in rails applications.}

  s.add_development_dependency("shoulda", [">= 2.11.3", "< 2.12.0"])
  s.add_development_dependency("mocha", [">= 0.9.10", "< 0.10.0"])
  s.add_development_dependency("activerecord", [">= 2.3.0"])
  s.add_development_dependency("activesupport", [">= 2.3.0"])
  s.add_development_dependency("sqlite3-ruby", [">= 1.3.2", "< 1.4.0"])
end
