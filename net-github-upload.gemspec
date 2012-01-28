# vim: fileencoding=utf-8
require File.expand_path("../lib/net/github-upload", __FILE__)

$version = Net::GitHub::Upload::VERSION
$readme = 'README.rdoc'
$rdoc_opts = %W(--main #{$readme} --charset utf-8 --line-numbers)
$name = 'net-github-upload'
$github_name = 'ruby-net-github-upload'
$summary = 'ruby porting of Net::GitHub::Upload'
$description = <<-EOS
Ruby Net::GitHub::Upload is upload user agent for GitHub Downloads
EOS
$author = 'Constellation'
$email = 'utatane.tea@gmail.com'
$page = 'http://github.com/Constellation/ruby-net-github-upload'
$rubyforge_project = 'ruby-net-github-upload'

Gem::Specification.new do |s|
  s.name = $name
  s.version = $version
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = [$readme]
  s.rdoc_options += $rdoc_opts
  s.summary = $summary
  s.description = $description
  s.author = $author
  s.email = $email
  s.homepage = $page
  s.executables = $exec
  s.rubyforge_project = $rubyforge_project
  s.require_path = 'lib'
  s.test_files = Dir["test/*_test.rb"]
  s.add_dependency('nokogiri', '>=1.4.0')
  s.add_dependency('faster_xml_simple')
  s.add_dependency('json')
  s.add_dependency('httpclient')
  s.files = %w(README.rdoc Rakefile) + Dir["{bin,test,lib}/**/*"]
end

# vim: syntax=ruby

