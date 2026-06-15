class Admin < ApplicationRecord
  belongs_to :departamento
  has_many :templates, dependent: :destroy
  has_many :formularios, dependent: :destroy
end
