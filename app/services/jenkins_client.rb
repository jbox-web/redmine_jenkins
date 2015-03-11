require 'jenkins_api_client'

class JenkinsClient

  def initialize(url, opts = {})
    @url = url

    @options = {}
    @options[:server_url] = @url
    @options[:http_open_timeout] = opts[:http_open_timeout] || 5
    @options[:http_read_timeout] = opts[:http_read_timeout] || 60
    @options[:username] = opts[:username] if opts.has_key?(:username)
    @options[:password] = opts[:password] if opts.has_key?(:password)
  end


  def connection
    JenkinsApi::Client.new(@options)
  rescue ArgumentError => e
    raise RedmineJenkins::Error::JenkinsConnectionError, e
  end


  def test_connection
    test = {}
    test[:errors] = []

    begin
      test[:jobs_count] = connection.job.list_all.size
    rescue => e
      test[:jobs_count] = 0
      test[:errors] << e.message
    end

    begin
      test[:version] = connection.get_jenkins_version
    rescue => e
      test[:version] = 0
      test[:errors] << e.message
    end

    return test
  end


  def get_jobs_list
    connection.job.list_all rescue []
  end


  def number_of_builds_for(job_name)
    connection.job.list_details(job_name)['builds'].size rescue 0
  end

end
