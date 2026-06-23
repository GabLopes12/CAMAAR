module FormulariosHelper
  def formatar_resposta(resposta, tipo)
    case tipo
    when "boolean"
      case resposta.valor_numerico
      when 1 then "Sim"
      when 0 then "Não"
      else "—"
      end
    when "rating"
      resposta.valor_numerico.nil? ? "—" : "#{resposta.valor_numerico}/5"
    else
      resposta.valor_texto.presence || "—"
    end
  end
end
