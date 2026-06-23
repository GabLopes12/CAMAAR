class Submissao < ApplicationRecord
  belongs_to :formulario
  belongs_to :user
  has_many :respostas, class_name: "Respostum", dependent: :destroy
end
