# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{icontact-api}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kevin Olbrich"]
  s.cert_chain = ["/Users/kolbrich/.gem/gem-public_cert.pem"]
  s.date = %q{2009-03-07}
  s.description = %q{This gem provides a thin wrapper around the iContact 2.0 API.}
  s.email = ["kevin.olbrich@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "lib/icontact-api.rb", "lib/icontact/api.rb", "script/console", "script/destroy", "script/generate", "spec/api_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{icontact-api}
  s.rubygems_version = %q{1.3.1}
  s.signing_key = %q{/Users/kolbrich/.gem/gem-private_key.pem}
  s.summary = %q{This gem provides a thin wrapper around the iContact 2.0 API.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 1.1.3"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<json>, [">= 1.1.3"])
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<json>, [">= 1.1.3"])
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end