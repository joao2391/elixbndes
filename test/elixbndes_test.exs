defmodule ElixBndesTest do
  use ExUnit.Case
  doctest ElixBndes

  test "retorna 66 bancos" do
    assert ElixBndes.get_bancos_credenciados() |> Enum.count == 66
  end
end
