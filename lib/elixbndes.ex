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
end
