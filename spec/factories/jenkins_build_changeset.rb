FactoryGirl.define do

  factory :jenkins_build_changeset do |f|
    f.revision { Faker::Number.number(9) }
  end

end
