FactoryGirl.define do

  factory :project do |f|
    f.name        { Faker::App.name }
    f.identifier  { Faker::Internet.user_name(nil, %w(- _)) }
  end

end
