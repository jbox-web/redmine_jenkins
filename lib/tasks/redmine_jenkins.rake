require 'ci/reporter/rake/rspec'

namespace :redmine_jenkins do

  namespace :ci do
    ENV["CI_REPORTS"] = Rails.root.join('junit').to_s
    task :all => ['ci:setup:rspec', 'spec']
  end


  desc "Show library version"
  task :version do
    puts "Redmine Jenkins #{version("plugins/redmine_jenkins/init.rb")}"
  end


  def version(path)
    line = File.read(Rails.root.join(path))[/^\s*version\s*.*/]
    line.match(/.*version\s*['"](.*)['"]/)[1]
  end

end
