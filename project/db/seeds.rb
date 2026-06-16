# Seed de desenvolvimento: cria um conjunto mínimo de dados para testar as
# telas (templates, formulários, turmas, alunos, professores, etc) na interface.
# Idempotente — pode ser rodado múltiplas vezes sem duplicar dados.

# ---------------------------------------------------------------------------
# Departamentos (domínio legado)
# ---------------------------------------------------------------------------
departamento_cic = Departamento.find_or_create_by!(code: "CIC") do |d|
  d.name = "Ciência da Computação"
end

departamento_ene = Departamento.find_or_create_by!(code: "ENE") do |d|
  d.name = "Engenharia Elétrica"
end

# ---------------------------------------------------------------------------
# Department (novo sistema de auth — tabela separada)
# ---------------------------------------------------------------------------
department_cic = Department.find_or_create_by!(code: "CIC") do |d|
  d.name = "Ciência da Computação"
end

# ---------------------------------------------------------------------------
# Usuário administrador (novo sistema — usado para login e posse de templates)
# ---------------------------------------------------------------------------
admin_user = User.find_or_create_by!(email: "admin.cic@unb.br") do |u|
  u.name         = "Admin CAMAAR"
  u.registration = "000000001"
  u.role         = :admin
  u.password     = "Senha@123"
  u.department   = department_cic
end

# ---------------------------------------------------------------------------
# Professores (domínio legado — relacionamento com Turma)
# ---------------------------------------------------------------------------
professor_ana = Professor.find_or_create_by!(matricula: "PROF0001") do |p|
  p.name           = "Ana Souza"
  p.email          = "ana.souza@unb.br"
  p.formation      = "Doutora em Ciência da Computação"
  p.departamento_id = departamento_cic.id
  p.password       = "Senha@123"
end

professor_bruno = Professor.find_or_create_by!(matricula: "PROF0002") do |p|
  p.name           = "Bruno Lima"
  p.email          = "bruno.lima@unb.br"
  p.formation      = "Doutor em Engenharia Elétrica"
  p.departamento_id = departamento_ene.id
  p.password       = "Senha@123"
end

# ---------------------------------------------------------------------------
# Alunos (domínio legado — relacionamento com TurmaAluno e Submissao)
# ---------------------------------------------------------------------------
alunos = [
  { matricula: "190000001", name: "Carla Mendes",   email: "carla.mendes@aluno.unb.br",   course: "Engenharia de Software" },
  { matricula: "190000002", name: "Diego Alves",    email: "diego.alves@aluno.unb.br",    course: "Engenharia de Software" },
  { matricula: "190000003", name: "Eduarda Rocha",  email: "eduarda.rocha@aluno.unb.br",  course: "Ciência da Computação" },
  { matricula: "190000004", name: "Felipe Castro",  email: "felipe.castro@aluno.unb.br",  course: "Ciência da Computação" }
].map do |dados|
  Aluno.find_or_create_by!(matricula: dados[:matricula]) do |a|
    a.name     = dados[:name]
    a.email    = dados[:email]
    a.course   = dados[:course]
    a.password = "Senha@123"
  end
end

# ---------------------------------------------------------------------------
# Turmas
# ---------------------------------------------------------------------------
turma_estrutura_dados = Turma.find_or_create_by!(class_code: "CIC0097-T01") do |t|
  t.subject_code    = "CIC0097"
  t.subject_name    = "Estrutura de Dados"
  t.semester        = "2026.1"
  t.time            = "Seg/Qua 08:00-10:00"
  t.departamento_id = departamento_cic.id
  t.professor_id    = professor_ana.id
end

turma_circuitos = Turma.find_or_create_by!(class_code: "ENE0011-T01") do |t|
  t.subject_code    = "ENE0011"
  t.subject_name    = "Circuitos Elétricos"
  t.semester        = "2026.1"
  t.time            = "Ter/Qui 10:00-12:00"
  t.departamento_id = departamento_ene.id
  t.professor_id    = professor_bruno.id
end

[ alunos[0], alunos[1], alunos[2] ].each do |aluno|
  TurmaAluno.find_or_create_by!(turma_id: turma_estrutura_dados.id, aluno_id: aluno.id)
end

[ alunos[2], alunos[3] ].each do |aluno|
  TurmaAluno.find_or_create_by!(turma_id: turma_circuitos.id, aluno_id: aluno.id)
end

# ---------------------------------------------------------------------------
# Templates (admin_id agora referencia users.id)
# ---------------------------------------------------------------------------
template_discente = Template.find_or_create_by!(title: "Avaliação de Disciplina - Discentes") do |t|
  t.target_role = "discente"
  t.admin_id    = admin_user.id
end

if template_discente.questaos.empty?
  template_discente.questaos.create!(enunciado: "O professor demonstrou domínio do conteúdo?", tipo: "rating")
  template_discente.questaos.create!(enunciado: "O material disponibilizado foi adequado?", tipo: "rating")
  template_discente.questaos.create!(enunciado: "Comentários e sugestões para a disciplina:", tipo: "text")
end

template_docente = Template.find_or_create_by!(title: "Autoavaliação - Docentes") do |t|
  t.target_role = "docente"
  t.admin_id    = admin_user.id
end

if template_docente.questaos.empty?
  template_docente.questaos.create!(enunciado: "Você conseguiu cumprir o plano de ensino proposto?", tipo: "boolean")
  template_docente.questaos.create!(enunciado: "Quais dificuldades você encontrou no semestre?", tipo: "text")
end

# ---------------------------------------------------------------------------
# Formulário de exemplo
# ---------------------------------------------------------------------------
formulario = Formulario.find_or_create_by!(title: "Avaliação Estrutura de Dados - 2026.1") do |f|
  f.target_role = template_discente.target_role
  f.admin_id    = admin_user.id
  f.template_id = template_discente.id
  f.turma_id    = turma_estrutura_dados.id
end

if formulario.questaos.empty?
  template_discente.questaos.each do |questao|
    formulario.questaos.create!(enunciado: questao.enunciado, tipo: questao.tipo)
  end
end

# ---------------------------------------------------------------------------
# Submissão de exemplo
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
puts "Seed concluída:"
puts "  Login admin: email=#{admin_user.email} / senha=Senha@123"
puts "  Professores: #{Professor.count} | Alunos: #{Aluno.count} | Turmas: #{Turma.count}"
puts "  Templates: #{Template.count} | Formulários: #{Formulario.count}"
puts "  Submissões: #{Submissao.count} | Respostas: #{Respostum.count}"
