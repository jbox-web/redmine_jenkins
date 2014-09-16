FactoryGirl.define do

  factory :jenkins_build do |f|
    f.number       { Faker::Number.number(3) }
    f.association  :author, factory: :user
  end

end
