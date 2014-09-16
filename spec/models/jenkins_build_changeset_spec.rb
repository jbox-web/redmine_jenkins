require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JenkinsBuildChangeset do

  before(:each) do
    project         = create(:project)
    repository      = create(:repository_git, project: project)
    jenkins_setting = create(:jenkins_setting, project: project)
    jenkins_job     = create(:jenkins_job, project: project, repository: repository, jenkins_setting: jenkins_setting)
    jenkins_build   = create(:jenkins_build, jenkins_job: jenkins_job)
    @jenkins_build_changeset = build(:jenkins_build_changeset, jenkins_build: jenkins_build, repository: repository)
  end

  subject { @jenkins_build_changeset }

  it { should be_valid }

  ## Test relations
  it { should belong_to(:jenkins_build) }
  it { should belong_to(:repository) }

  ## Test validation
  it { should validate_presence_of(:jenkins_build_id) }
  it { should validate_presence_of(:repository_id) }
  it { should validate_presence_of(:revision) }

  it { should validate_uniqueness_of(:revision).scoped_to(:jenkins_build_id) }
end
