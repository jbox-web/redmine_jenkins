module RedmineJenkins
  module Error

    # Used to register errors when pulling and pushing the conf file
    class JenkinsException       < StandardError; end
    class JenkinsConnectionError < JenkinsException; end

  end
end
