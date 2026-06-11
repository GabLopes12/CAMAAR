json.extract! aluno, :id, :matricula, :name, :email, :password_digest, :course, :created_at, :updated_at
json.url aluno_url(aluno, format: :json)
