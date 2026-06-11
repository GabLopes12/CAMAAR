json.extract! admin, :id, :username, :name, :email, :password_digest, :departamento_id, :created_at, :updated_at
json.url admin_url(admin, format: :json)
