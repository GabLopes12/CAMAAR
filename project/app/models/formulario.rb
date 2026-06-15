class Formulario < ApplicationRecord
  # O template pode ser desvinculado (ficar nulo) se o Admin deletar o template
  # de origem; o formulário e suas questões clonadas permanecem intactos.
  belongs_to :template, optional: true
  belongs_to :turma, optional: true
  belongs_to :admin
  has_many :questaos, dependent: :destroy

  validates :title, presence: { message: "O nome do formulário é obrigatório" }
  validates :template_id, presence: { message: "É necessário escolher um template base" }, on: :create
  validates :turma_id, presence: { message: "É necessário escolher ao menos uma turma" }, on: :create

  after_initialize { self.status ||= "draft" }
end
