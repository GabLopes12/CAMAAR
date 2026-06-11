json.extract! professor, :id, :matricula, :name, :email, :password_digest, :formation, :departamento_id, :created_at, :updated_at
json.url professor_url(professor, format: :json)
