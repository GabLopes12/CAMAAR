FactoryBot.define do
  factory :submissao do
    formulario
    association :participant, factory: :aluno

    trait :de_professor do
      association :participant, factory: :professor
    end
  end
end
