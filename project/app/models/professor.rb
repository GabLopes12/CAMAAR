class Professor < ApplicationRecord
  belongs_to :departamento
  has_secure_password
  has_many :turmas
  has_many :submissoes, as: :participant
end