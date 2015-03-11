require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do

  let(:project){ build(:project) }

  subject { project }

  it { should be_valid }

  ## Test relations
  it { should have_one(:jenkins_setting).dependent(:destroy) }
  it { should have_many(:jenkins_jobs).dependent(:destroy) }

end
