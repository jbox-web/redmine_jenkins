require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JenkinsSetting do

  before(:each) do
    project          = create(:project)
    @jenkins_setting = build(:jenkins_setting, project: project)
  end

  subject { @jenkins_setting }

  it { should be_valid }

  ## Test relations
  it { should belong_to(:project) }
  it { should have_many(:jobs).class_name('JenkinsJob').dependent(:destroy) }

  ## Test validation
  it { should validate_presence_of(:project_id) }
  it { should validate_presence_of(:url) }

  it { should validate_uniqueness_of(:project_id) }
end
