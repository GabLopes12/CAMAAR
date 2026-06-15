module TestHelpers
  def departamento_de_teste
    Departamento.find_or_create_by!(code: "DEPT001") do |departamento|
      departamento.name = "Departamento de Teste"
    end
  end

  def criar_admin
    departamento = departamento_de_teste
    sufixo = SecureRandom.hex(4)

    Admin.create!(
      name: "Admin Teste #{sufixo}",
      email: "admin#{sufixo}@teste.com",
      username: "admin#{sufixo}",
      departamento_id: departamento.id
    )
  end

  def criar_template_com_questao(admin, titulo: "Template #{SecureRandom.hex(4)}", target_role: "discente", enunciado: "Qual é a resposta correta?")
    template = admin.templates.create!(title: titulo, target_role: target_role)
    template.questaos.create!(enunciado: enunciado, tipo: "text")
    template
  end

  def criar_turma
    departamento = departamento_de_teste
    sufixo = SecureRandom.hex(4)

    professor = Professor.create!(
      name: "Professor Teste #{sufixo}",
      email: "professor#{sufixo}@teste.com",
      matricula: "PROF#{sufixo}",
      password: "senha12345",
      departamento_id: departamento.id
    )

    Turma.create!(
      class_code: "TURMA#{sufixo}",
      subject_code: "DISC#{sufixo}",
      subject_name: "Disciplina Teste",
      semester: "2026.1",
      time: "10:00",
      departamento_id: departamento.id,
      professor_id: professor.id
    )
  end
end

World(TestHelpers)
