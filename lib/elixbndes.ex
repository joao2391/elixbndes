defmodule ElixBndes do
  @moduledoc """
  Documentation for `ElixBndes`.
  """
  require Logger
  alias ElixBndes.Banco

  @doc """
  Busca os bancos credenciados.
  """
  def get_bancos_credenciados() do
    case HTTPoison.get(
           "https://www.bndes.gov.br/wps/portal/site/home/instituicoes-financeiras-credenciadas/rede-credenciada-brasil",
           %{"User-Agent" => "elixbndes/1.0.1"}
         ) do
      {:ok, %{body: raw_body, status_code: _code}} ->
        html = raw_body

        {:ok, document} = Floki.parse_document(html)

        document
        |> Floki.find("h2[class*=fechado]")
        |> Enum.map(fn {_chave, _valor1, valor2} -> %Banco{nome: Enum.at(valor2, 0)} end)

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(inspect(reason))
    end
  end

  @doc """
  Busca os fornecedores cadastrados no BNDES pelo nome.
  """
  def get_fornecedores_by_nome(nomeFornecedor, pagina \\ 1) do
    case HTTPoison.get(
           "https://www.cartaobndes.gov.br/cartaobndes/Servico/Fornecedores.asp?acao=busca&chr_tiposaida=JSON&fornecedor=#{nomeFornecedor}&pagina=#{pagina}",
           [{"User-Agent", "elixbndes/1.0.1"}, {"Accept", "*/*"}]
         ) do
      {:ok, %{body: raw_body, status_code: _code}} ->
        retorno = Jason.decode!(raw_body)

        retorno["Catalogo"]
    end
  end
end
