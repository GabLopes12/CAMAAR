class Departamento < ApplicationRecord
  has_many :admins
  has_many :professors
  has_many :turmas
end