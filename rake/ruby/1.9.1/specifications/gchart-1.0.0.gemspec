# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gchart}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Barnette", "Jim Ludwig"]
  s.date = %q{2009-08-11}
  s.description = %q{GChart exposes the Google Chart API via a friendly Ruby interface. It
can generate the URL for a given chart (for webpage use), or download
the generated PNG (for offline use).}
  s.email = ["jbarnette@rubyforge.org", "supplanter@rubyforge.org"]
  s.homepage = %q{http://github.com/jbarnette/gchart}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gchart}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{GChart exposes the Google Chart API via a friendly Ruby interface}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
