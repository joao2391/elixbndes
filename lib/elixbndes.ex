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
  def get_fornecedores_by_nome(nome_fornecedor, pagina \\ 1) when is_bitstring(nome_fornecedor) do
    case HTTPoison.get(
           "https://www.cartaobndes.gov.br/cartaobndes/Servico/Fornecedores.asp?acao=busca&chr_tiposaida=JSON&fornecedor=#{nome_fornecedor}&pagina=#{pagina}",
           [{"User-Agent", "elixbndes/1.0.1"}, {"Accept", "*/*"}]
         ) do
      {:ok, %{body: raw_body, status_code: _code}} ->
        retorno = Jason.decode!(raw_body)

        retorno["Catalogo"]
    end
  end

  @doc """
   Busca os fornecedores cadastrados no BNDES pelo nome do produto.
  """
  def get_fornecedores_by_nome_produto(nome_produto, pagina \\ 1) when is_bitstring(nome_produto) do
    case HTTPoison.get(
           "https://www.cartaobndes.gov.br/cartaobndes/Servico/Fornecedores.asp?acao=busca&chr_tiposaida=JSON&produto=#{nome_produto}&pagina=#{pagina}",
           [{"User-Agent", "elixbndes/1.0.1"}, {"Accept", "*/*"}]
         ) do
      {:ok, %{body: raw_body, status_code: _code}} ->
        retorno = Jason.decode!(raw_body)

        retorno["Catalogo"]
    end
  end

  @doc """
   Busca os Busca os produtos cadastrados no BNDES pelo nome.
  """
  def get_produtos_by_nome(nome_produto, pagina \\ 1) when is_bitstring(nome_produto) do
    case HTTPoison.post(
      "https://www.cartaobndes.gov.br/cartaobndes/PaginasCartao/Catalogo.asp?Acao=LP&CTRL=",
      {:form, [{"chr_PalavraPesquisadaHidden", nome_produto}, {"int_PaginaAtual", pagina}]},
      %{"Content-Type" => "application/x-www-form-urlencoded", "source" => "elixbndes"}
      ) do
        {:ok, %{body: raw_body, status_code: _code}} ->
          html = raw_body

          {:ok, document} = Floki.parse_document(html)

          #qtde_produtos = get_quantidade_produtos_by_regex(nome_produto)
          #|> Floki.find("a[id*=cat_anchor]") |> Enum.map(fn {_chave, _valor1, valor2} -> valor2 end)
          #Floki.find("tr[class=texto1]")


          document |> Floki.find("table[class=Tabela1]") |> Floki.find("tr[valign=top")
      end

  end

  defp get_quantidade_produtos_by_regex(nome_produto) do
    case HTTPoison.post(
      "https://www.cartaobndes.gov.br/cartaobndes/PaginasCartao/Catalogo.asp?Acao=RBS&CTRL=",
      #{:form, [{"chr_PalavraPesquisadaHidden", nome_produto}, {"int_PaginaAtual", pagina}]},
      {:form, [{"chr_PalavraPesquisadaHidden", nome_produto}, {"chr_PalavraPesquisada", nome_produto}]},
      %{"Content-Type" => "application/x-www-form-urlencoded", "source" => "elixbndes"}
      ) do
        {:ok, %{body: raw_body, status_code: _code}} ->
          html = raw_body

          {:ok, document} = Floki.parse_document(html)

          document |> Floki.find("a[id=qtdeprod_anchor5]")  |> Floki.text() |> String.replace(~r/[^\d]/,"") |> String.to_integer()

          #a id="qtdeprod_anchor5" ("table[class=Tabela1]")
          #String.replace("Foram encontradas 143 refer├¬ncia(s)", ~r/[^\d]/,"") |> String.to_integer()
      end
  end


end
