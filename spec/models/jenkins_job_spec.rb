require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JenkinsJob do

  before(:each) do
    project         = create(:project)
    repository      = create(:repository_git, project: project)
    jenkins_setting = create(:jenkins_setting, project: project)

    @jenkins_job = build(:jenkins_job, project: project, repository: repository, jenkins_setting: jenkins_setting)
  end

  subject { @jenkins_job }

  it { should be_valid }

  ## Test relations
  it { should belong_to(:project) }
  it { should belong_to(:repository) }
  it { should belong_to(:jenkins_setting) }
  it { should have_many(:builds).class_name('JenkinsBuild').dependent(:destroy) }

  ## Test validation
  it { should validate_presence_of(:project_id) }
  it { should validate_presence_of(:repository_id) }
  it { should validate_presence_of(:jenkins_setting_id) }
  it { should validate_presence_of(:name) }

  it { should validate_uniqueness_of(:name).scoped_to(:jenkins_setting_id) }

  ## Test Serializations
  it { should serialize(:health_report).as(Array) }

  ## Test Delegators
  it { should delegate_method(:jenkins_connection).to(:jenkins_setting) }
  it { should delegate_method(:wait_for_build_id).to(:jenkins_setting) }
end
