require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do

  before(:each) do
    @project = build(:project)
  end

  subject { @project }

  it { should be_valid }

  ## Test relations
  it { should have_one(:jenkins_setting).dependent(:destroy) }

end
