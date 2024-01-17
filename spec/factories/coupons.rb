FactoryBot.define do
  factory :coupon do
    name { "MyString" }
    code { "MyString" }
    discount { 1.5 }
    merchant { nil }
  end
end
