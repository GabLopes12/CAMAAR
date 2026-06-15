# Step definitions para features/admin_criar_formulario.feature (#103)

Dado("que sou administrador") do
  @admin = criar_admin
end

Dado("existe pelo menos um template criado por mim") do
  @template = criar_template_com_questao(@admin)
end

Dado("existe pelo menos uma turma cadastrada") do
  @turma = criar_turma
end

Quando("eu preencher o nome do formulário") do
  @formulario_titulo = "Formulário Avaliação #{SecureRandom.hex(4)}"
  visit new_formulario_path(admin_id: @admin.id)
  fill_in "formulario[title]", with: @formulario_titulo
end

Quando("selecionar o template e a turma desejada") do
  select @template.title, from: "formulario[template_id]"
  select @turma.subject_name, from: "formulario[turma_id]"
end

Quando("clicar no botão 'Enviar'") do
  click_button "Enviar"
end

Então("devo ver uma mensagem dizendo 'Formulário gerado com sucesso!'") do
  expect(page).to have_text("Formulário gerado com sucesso!")
end

Então("as questões do template devem ser clonadas para o novo formulário") do
  formulario = Formulario.find_by!(title: @formulario_titulo)

  expect(formulario.questaos.count).to eq(@template.questaos.count)
  expect(formulario.questaos.pluck(:enunciado)).to eq(@template.questaos.pluck(:enunciado))
  expect(formulario.questaos.pluck(:template_id).uniq).to eq([ nil ])
end

Dado("que sou um administrador") do
  @admin = criar_admin
end

Dado("estou criando um formulário") do
  @template = criar_template_com_questao(@admin)
  @turma = criar_turma
  visit new_formulario_path(admin_id: @admin.id)
end

Quando("eu tentar criar um formulário sem selecionar nenhum template") do
  fill_in "formulario[title]", with: "Formulário sem template"
  select @turma.subject_name, from: "formulario[turma_id]"
  click_button "Enviar"
end

Então("o sistema deve exibir uma mensagem dizendo 'É necessário escolher um template base'") do
  expect(page).to have_text("É necessário escolher um template base")
end

Quando("eu tentar criar um formulário sem selecionar nenhuma turma") do
  fill_in "formulario[title]", with: "Formulário sem turma"
  select @template.title, from: "formulario[template_id]"
  click_button "Enviar"
end

Então("o sistema deve exibir uma mensagem dizendo 'É necessário escolher ao menos uma turma'") do
  expect(page).to have_text("É necessário escolher ao menos uma turma")
end
