class TurmaAluno < ApplicationRecord
  belongs_to :aluno
  belongs_to :turma
end
