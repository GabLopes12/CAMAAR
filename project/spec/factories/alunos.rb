FactoryBot.define do
  factory :aluno do
    sequence(:matricula) { |n| "19#{n.to_s.rjust(7, '0')}" }
    sequence(:email) { |n| "aluno#{n}@teste.com" }
    name { "Aluno Teste" }
    course { "Engenharia de Software" }
    password { "senha12345" }
  end
end
