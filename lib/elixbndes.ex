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

        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error(inspect(reason))
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

        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error(inspect(reason))
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

          #Checar form do captcha
          #ElixBndes.get_produtos_by_nome("cimento",1) |> Floki.find("form[id=frmCaptcha]") |> Floki.find("input[value=S]")
          #Case para validar o form do captcha:
          #xpto = ElixBndes.get_produtos_by_nome("cimento",1) |> Floki.find("form[id=frmCaptcha]") |> Floki.find("input[value=S]") |> Enum.count()
          # case 1 do
          # ^xpto -> "retornavel"
          # _ -> "retornavel"
          #end

          valida_captcha(document)

          #length(lista_enderecos)
          tamanho_lista = 10
          lista_produtos = get_produtos(document)
          lista_fabricantes = get_fornecedores(document)

        for x <- 0..tamanho_lista-1 do
          produto = lista_produtos |> Enum.at(x)
          fabricante = lista_fabricantes |> Enum.at(x)

          %{produto: produto, fabricante: fabricante}
        end

        #document

        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error(inspect(reason))
      end

  end

  defp valida_captcha(document) do
    is_on = document
              |> Floki.find("form[id=frmCaptcha]")
              |> Floki.find("input[value=S]")
              |> Enum.count()

    case 1 do
      ^is_on -> Logger.error("captcha ativo")
      _ -> Logger.info("captcha nao ativo")
    end

  end

  defp get_produtos(document) do

    document |> Floki.find("table[class=Tabela1]") |> Floki.find("tr[valign=top")
                   |> Floki.find("a[id*=cat_anchor]")
                   |> Floki.find("a[onclick^=JavaScript")
                   |> Enum.map(fn {_chave, _valor1, valor2} -> valor2 |> Floki.text() end)
  end

  defp get_fornecedores(document) do

    document |> Floki.find("table[class=Tabela1]") |> Floki.find("tr[valign=top")
                   |> Floki.find("a[id*=cat_anchor]")
                   |> Floki.find("a[href^=Catalogo]")
                   |> Enum.map(fn {_chave, _valor1, valor2} -> valor2 |> Floki.text() end)

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
