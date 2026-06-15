FactoryBot.define do
  factory :professor do
    departamento
    sequence(:matricula) { |n| "PROF#{n.to_s.rjust(4, '0')}" }
    sequence(:email) { |n| "professor#{n}@teste.com" }
    name { "Professor Teste" }
    formation { "Doutor em Ciência da Computação" }
    password { "senha12345" }
  end
end
