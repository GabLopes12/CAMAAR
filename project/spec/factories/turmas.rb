FactoryBot.define do
  factory :turma do
    departamento
    professor
    sequence(:class_code) { |n| "TURMA#{n}" }
    sequence(:subject_code) { |n| "DISC#{n}" }
    subject_name { "Disciplina Teste" }
    semester { "2026.1" }
    time { "10:00" }
  end
end
