class Aluno < ApplicationRecord
  has_secure_password # Habilita a criptografia da senha usando bcrypt
  has_many :turma_alunos
  has_many :turmas, through: :turma_alunos
  has_many :submissoes, as: :participant
end