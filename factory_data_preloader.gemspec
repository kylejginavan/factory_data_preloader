# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{factory_data_preloader}
  s.version = "1.0.0.beta0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Myron Marston"]
  s.date = %q{2009-07-09}
  s.email = %q{myron.marston@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["CHANGELOG.rdoc",
             "README.rdoc",
             "VERSION.yml",
             "lib/factory_data_preloader",
             "lib/factory_data_preloader/core_ext.rb",
             "lib/factory_data_preloader/factory_data.rb",
             "lib/factory_data_preloader/preloaded_data_hash.rb",
             "lib/factory_data_preloader/preloader.rb",
             "lib/factory_data_preloader/preloader_collection.rb",
             "lib/factory_data_preloader/rails_core_ext.rb",
             "lib/factory_data_preloader/railtie.rb",
             "lib/factory_data_preloader.rb",
             "test/factory_data_test.rb",
             "test/lib",
             "test/lib/models.rb",
             "test/lib/schema.rb",
             "test/preloaded_data_hash_test.rb",
             "test/preloader_test.rb",
             "test/test_helper.rb",
             "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/myronmarston/factory_data_preloader}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A library for preloading test data in rails applications.}

  s.add_development_dependency("shoulda", [">= 0"])
  s.add_development_dependency("mocha", [">= 0"])
  s.add_development_dependency("activerecord", [">= 0"])
  s.add_development_dependency("activesupport", [">= 0"])
  s.add_development_dependency("jeweler", [">= 0"])
  s.add_development_dependency("sqlite3-ruby", [">= 0"])
end
