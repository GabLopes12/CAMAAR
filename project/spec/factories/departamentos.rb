FactoryBot.define do
  factory :departamento do
    sequence(:code) { |n| "DEPT#{n.to_s.rjust(3, '0')}" }
    name { "Departamento de Teste" }
  end
end
