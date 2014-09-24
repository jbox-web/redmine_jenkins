namespace :redmine_jenkins do

  namespace :ci do
    begin
      require 'ci/reporter/rake/rspec'

      RSpec::Core::RakeTask.new do |task|
        task.rspec_opts = "plugins/redmine_jenkins/spec --color"
      end
    rescue Exception => e
    else
      ENV["CI_REPORTS"] = Rails.root.join('junit').to_s
    end

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
