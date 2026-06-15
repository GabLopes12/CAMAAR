# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Seed de desenvolvimento: cria um conjunto mínimo de dados para testar as
# telas (templates, formulários, turmas, alunos, professores, etc) na interface.

departamento_cic = Departamento.find_or_create_by!(code: "CIC") do |departamento|
  departamento.name = "Ciência da Computação"
end

departamento_ene = Departamento.find_or_create_by!(code: "ENE") do |departamento|
  departamento.name = "Engenharia Elétrica"
end

admin = Admin.find_or_create_by!(username: "admin") do |admin|
  admin.name = "Admin CAMAAR"
  admin.email = "admin.cic@unb.br"
  admin.departamento_id = departamento_cic.id
end

professor_ana = Professor.find_or_create_by!(matricula: "PROF0001") do |professor|
  professor.name = "Ana Souza"
  professor.email = "ana.souza@unb.br"
  professor.formation = "Doutora em Ciência da Computação"
  professor.departamento_id = departamento_cic.id
  professor.password = "Senha@123"
end

professor_bruno = Professor.find_or_create_by!(matricula: "PROF0002") do |professor|
  professor.name = "Bruno Lima"
  professor.email = "bruno.lima@unb.br"
  professor.formation = "Doutor em Engenharia Elétrica"
  professor.departamento_id = departamento_ene.id
  professor.password = "Senha@123"
end

alunos = [
  { matricula: "190000001", name: "Carla Mendes", email: "carla.mendes@aluno.unb.br", course: "Engenharia de Software" },
  { matricula: "190000002", name: "Diego Alves", email: "diego.alves@aluno.unb.br", course: "Engenharia de Software" },
  { matricula: "190000003", name: "Eduarda Rocha", email: "eduarda.rocha@aluno.unb.br", course: "Ciência da Computação" },
  { matricula: "190000004", name: "Felipe Castro", email: "felipe.castro@aluno.unb.br", course: "Ciência da Computação" }
].map do |dados|
  Aluno.find_or_create_by!(matricula: dados[:matricula]) do |aluno|
    aluno.name = dados[:name]
    aluno.email = dados[:email]
    aluno.course = dados[:course]
    aluno.password = "Senha@123"
  end
end

turma_estrutura_dados = Turma.find_or_create_by!(class_code: "CIC0097-T01") do |turma|
  turma.subject_code = "CIC0097"
  turma.subject_name = "Estrutura de Dados"
  turma.semester = "2026.1"
  turma.time = "Seg/Qua 08:00-10:00"
  turma.departamento_id = departamento_cic.id
  turma.professor_id = professor_ana.id
end

turma_circuitos = Turma.find_or_create_by!(class_code: "ENE0011-T01") do |turma|
  turma.subject_code = "ENE0011"
  turma.subject_name = "Circuitos Elétricos"
  turma.semester = "2026.1"
  turma.time = "Ter/Qui 10:00-12:00"
  turma.departamento_id = departamento_ene.id
  turma.professor_id = professor_bruno.id
end

[ alunos[0], alunos[1], alunos[2] ].each do |aluno|
  TurmaAluno.find_or_create_by!(turma_id: turma_estrutura_dados.id, aluno_id: aluno.id)
end

[ alunos[2], alunos[3] ].each do |aluno|
  TurmaAluno.find_or_create_by!(turma_id: turma_circuitos.id, aluno_id: aluno.id)
end

template_discente = Template.find_or_create_by!(title: "Avaliação de Disciplina - Discentes") do |template|
  template.target_role = "discente"
  template.admin_id = admin.id
end

if template_discente.questaos.empty?
  template_discente.questaos.create!(enunciado: "O professor demonstrou domínio do conteúdo?", tipo: "rating")
  template_discente.questaos.create!(enunciado: "O material disponibilizado foi adequado?", tipo: "rating")
  template_discente.questaos.create!(enunciado: "Comentários e sugestões para a disciplina:", tipo: "text")
end

template_docente = Template.find_or_create_by!(title: "Autoavaliação - Docentes") do |template|
  template.target_role = "docente"
  template.admin_id = admin.id
end

if template_docente.questaos.empty?
  template_docente.questaos.create!(enunciado: "Você conseguiu cumprir o plano de ensino proposto?", tipo: "boolean")
  template_docente.questaos.create!(enunciado: "Quais dificuldades você encontrou no semestre?", tipo: "text")
end

formulario = Formulario.find_or_create_by!(title: "Avaliação Estrutura de Dados - 2026.1") do |formulario|
  formulario.target_role = template_discente.target_role
  formulario.admin_id = admin.id
  formulario.template_id = template_discente.id
  formulario.turma_id = turma_estrutura_dados.id
end

if formulario.questaos.empty?
  template_discente.questaos.each do |questao|
    formulario.questaos.create!(enunciado: questao.enunciado, tipo: questao.tipo)
  end
end

submissao = Submissao.find_or_create_by!(formulario_id: formulario.id, participant: alunos[0])

if Respostum.where(submissao_id: submissao.id).empty?
  formulario.questaos.each do |questao|
    if questao.tipo == "rating"
      Respostum.create!(submissao_id: submissao.id, questao_id: questao.id, valor_numerico: 5)
    else
      Respostum.create!(submissao_id: submissao.id, questao_id: questao.id, valor_texto: "Resposta de exemplo")
    end
  end
end

puts "Seed concluída:"
puts "  Admin: #{admin.username} (id=#{admin.id}) - use ?admin_id=#{admin.id} enquanto a #104 não existe"
puts "  Professores: #{Professor.count} | Alunos: #{Aluno.count} | Turmas: #{Turma.count}"
puts "  Templates: #{Template.count} | Formulários: #{Formulario.count}"
puts "  Submissões: #{Submissao.count} | Respostas: #{Respostum.count}"
