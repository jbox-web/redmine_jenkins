require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JenkinsBuild do

  before(:each) do
    project         = create(:project)
    repository      = create(:repository_git, project: project)
    jenkins_setting = create(:jenkins_setting, project: project)
    jenkins_job     = create(:jenkins_job, project: project, repository: repository, jenkins_setting: jenkins_setting)
    @jenkins_build  = build(:jenkins_build, jenkins_job: jenkins_job)
  end

  subject { @jenkins_build }

  it { should be_valid }

  ## Test relations
  it { should belong_to(:jenkins_job) }
  it { should belong_to(:author).class_name('User').with_foreign_key('author_id') }
  it { should have_many(:changesets).class_name('JenkinsBuildChangeset').dependent(:destroy) }

  ## Test validation
  it { should validate_presence_of(:jenkins_job_id) }
  it { should validate_presence_of(:author_id) }
  it { should validate_presence_of(:number) }

  it { should validate_uniqueness_of(:number).scoped_to(:jenkins_job_id) }

  ## Test Delegators
  it { should delegate_method(:project).to(:jenkins_job) }
end
