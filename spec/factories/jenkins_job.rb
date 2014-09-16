FactoryGirl.define do

  factory :jenkins_job do |f|
    f.name { Faker::Name.name }
  end

end
