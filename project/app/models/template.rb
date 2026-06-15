class Template < ApplicationRecord
  belongs_to :admin
  has_many :questaos, dependent: :destroy
  has_many :formularios, dependent: :nullify

  validates :title, presence: { message: "O nome do template é obrigatório" }
end
