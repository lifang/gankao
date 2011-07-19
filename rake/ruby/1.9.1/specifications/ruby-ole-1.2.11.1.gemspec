# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-ole}
  s.version = "1.2.11.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Lowe"]
  s.date = %q{2010-10-24}
  s.default_executable = %q{oletool}
  s.description = %q{A library for easy read/write access to OLE compound documents for Ruby.}
  s.email = %q{aquasync@gmail.com}
  s.executables = ["oletool"]
  s.files = ["test/test_property_set.rb", "test/test_storage.rb", "test/test_mbat.rb", "test/test_meta_data.rb", "test/test_support.rb", "test/test_types.rb", "test/test_ranges_io.rb", "test/test_filesystem.rb", "bin/oletool"]
  s.homepage = %q{http://code.google.com/p/ruby-ole}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-ole}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Ruby OLE library.}
  s.test_files = ["test/test_property_set.rb", "test/test_storage.rb", "test/test_mbat.rb", "test/test_meta_data.rb", "test/test_support.rb", "test/test_types.rb", "test/test_ranges_io.rb", "test/test_filesystem.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
