FactoryBot.define do
  factory :admin do
    departamento
    sequence(:username) { |n| "admin#{n}" }
    sequence(:email) { |n| "admin#{n}@teste.com" }
    name { "Admin Teste" }
  end
end
