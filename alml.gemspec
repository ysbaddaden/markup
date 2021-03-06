# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{alml}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Julien Portalier"]
  s.date = %q{2011-05-04}
  s.description = %q{Another Lightweight Markup Language.}
  s.email = %q{ysbaddaden@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "README.rdoc",
    "lib/markup.rb",
    "lib/markup/html.rb"
  ]
  s.homepage = %q{http://github.com/ysbaddaden/markup}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Another Lightweight Markup Language.}
  s.test_files = [
    "test/formatters/html_test.rb",
    "test/parser/blocks_test.rb",
    "test/parser/inlines_test.rb",
    "test/parser/smart_punctuation_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0.7"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3.0.7"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.0.7"])
  end
end

