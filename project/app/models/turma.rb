class Turma < ApplicationRecord
  belongs_to :departamento
  belongs_to :professor
  has_many :turma_alunos
  has_many :alunos, through: :turma_alunos # Resolve o relacionamento N:N
  has_many :formularios
end