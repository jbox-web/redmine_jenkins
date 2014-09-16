FactoryGirl.define do

  factory :jenkins_setting do |f|
    f.url { Faker::Internet.url }
  end

end
