defmodule ElixBndesTest do
  use ExUnit.Case
  doctest ElixBndes

  test "retorna 66 bancos" do
    assert ElixBndes.get_bancos_credenciados() |> Enum.count() == 66
  end

  test "retorna 09 fornecedores" do
    assert ElixBndes.get_fornecedores_by_nome("Zezinho", 1) |> Enum.count() == 9
  end

end
