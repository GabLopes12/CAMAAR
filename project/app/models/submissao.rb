class Submissao < ApplicationRecord
  belongs_to :formulario
  belongs_to :participant, polymorphic: true
end
