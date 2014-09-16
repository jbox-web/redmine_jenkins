FactoryGirl.define do

  factory :repository_git, :class => 'Repository::Git' do |f|
    f.is_default  false
  end

end
