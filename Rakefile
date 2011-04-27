%w[rubygems rake rake/clean].each { |f| require f }
require File.dirname(__FILE__) + '/lib/icontact-api'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "icontact-api"
    gem.summary = %Q{A thin wrapper around the iContact API}
    gem.authors = ["Kevin Olbrich"]
    gem.email = ["kevin.olbrich+icontact-api@gmail.com"]
    gem.homepage = "http://github.com/olbrich/IContact-API"
	end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

