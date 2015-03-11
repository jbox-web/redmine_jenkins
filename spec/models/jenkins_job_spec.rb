require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JenkinsJob do

  let(:project){ create(:project) }
  let(:repository){ create(:repository_git, project: project) }
  let(:jenkins_setting){ create(:jenkins_setting, project: project) }
  let(:jenkins_job){ build(:jenkins_job, project: project, repository: repository) }

  subject { jenkins_job }

  it { should be_valid }

  ## Test relations
  it { should belong_to(:project) }
  it { should belong_to(:repository) }
  it { should have_many(:builds).class_name('JenkinsBuild').dependent(:destroy) }

  ## Test validation
  it { should validate_presence_of(:project_id) }
  it { should validate_presence_of(:repository_id) }
  it { should validate_presence_of(:name) }

  it { should validate_uniqueness_of(:name).scoped_to(:project_id) }

  ## Test Serializations
  it { should serialize(:health_report).as(Array) }

  ## Test Delegators
  it { should delegate_method(:jenkins_connection).to(:project) }
  it { should delegate_method(:jenkins_url).to(:project) }
  it { should delegate_method(:wait_for_build_id).to(:project) }
end
