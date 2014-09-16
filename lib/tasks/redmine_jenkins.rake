# require 'rspec'
# require 'rspec/core/rake_task'

namespace :redmine_jenkins do

  desc "Show library version"
  task :version do
    puts "Redmine Jenkins #{version("plugins/redmine_jenkins/init.rb")}"
  end


  desc "Start unit tests"
  task :test => :default
  task :default => [:environment] do
    RSpec::Core::RakeTask.new(:spec) do |config|
      config.rspec_opts = "plugins/redmine_jenkins/spec --color"
    end
    Rake::Task["spec"].invoke
  end


  def version(path)
    line = File.read(Rails.root.join(path))[/^\s*version\s*.*/]
    line.match(/.*version\s*['"](.*)['"]/)[1]
  end

end
