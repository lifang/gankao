# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{weibo}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Ballantyne"]
  s.date = %q{2011-01-11}
  s.description = %q{this gem is an adaptation of John Nunemaker's Twitter gem.  I modified it to make api integration for æ°æµªå¾®å (t.sina.com.cn) easier.}
  s.email = %q{ussballantyne@gmail.com}
  s.files = ["test/helper.rb", "test/test_weibo.rb"]
  s.homepage = %q{http://github.com/ballantyne/weibo}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{a gem to help api integration for æ°æµªå¾®å (t.sina.com.cn)}
  s.test_files = ["test/helper.rb", "test/test_weibo.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_runtime_dependency(%q<oauth>, ["~> 0.4.1"])
      s.add_runtime_dependency(%q<hashie>, [">= 0"])
      s.add_runtime_dependency(%q<httparty>, [">= 0.5.2"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<oauth>, ["~> 0.4.1"])
      s.add_dependency(%q<hashie>, [">= 0"])
      s.add_dependency(%q<httparty>, [">= 0.5.2"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<oauth>, ["~> 0.4.1"])
    s.add_dependency(%q<hashie>, [">= 0"])
    s.add_dependency(%q<httparty>, [">= 0.5.2"])
  end
end
