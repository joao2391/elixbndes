defmodule ElixBndesTest do
  use ExUnit.Case
  doctest ElixBndes

  test "retorna 66 bancos" do
    assert ElixBndes.get_bancos_credenciados() |> Enum.count() == 66
  end

  test "retorna 09 fornecedores" do
    assert ElixBndes.get_fornecedores_by_nome("Zezinho", 1) |> Enum.count() == 9
  end

  test "retorna 25 fornecedores" do
    assert ElixBndes.get_fornecedores_by_nome_produto("cimento", 1) |> Enum.count() == 25
  end

  test "retorna 10 itens" do
    lista = ElixBndes.get_produtos_by_nome("cimento",1)
    assert lista.itens |> Enum.count() == 10
  end

end
