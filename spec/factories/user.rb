FactoryGirl.define do

  factory :user do |f|
    f.login              { Faker::Internet.user_name(nil, %w(-)) }
    f.firstname          { Faker::Name.first_name }
    f.lastname           { Faker::Name.last_name }
    f.mail               { Faker::Internet.free_email }
    f.language           "fr"
    f.hashed_password    "66eb4812e268747f89ec309178e2ea50410653fb"
    f.salt               "5abd4e59ac0d483daf2f68d3b6544ff3"
  end

end
