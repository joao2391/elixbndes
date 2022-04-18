[![ElixBndes version](https://img.shields.io/hexpm/v/elixbndes.svg)](https://hex.pm/packages/elixbndes)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/elixbndes/)
[![Hex.pm](https://img.shields.io/hexpm/dt/elixbndes.svg)](https://hex.pm/packages/)

# ElixBndes

This lib helps you to get infos about BNDES card. This is not the official lib from BNDES!

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elixbndes` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixbndes, "~> 0.1.0"}
  ]
end
```

## Features
```elixir

get_bancos_credenciados()

get_fornecedores_by_nome("Nome_do_fornecedor", 1)

get_fornecedores_by_nome_produto("nome_do_produto", 1)

get_produtos_by_nome("nome_do_produto", 1)

```

## Documentation

Documentation can be found at [https://hexdocs.pm/elixbndes](https://hexdocs.pm/elixbndes).

## License
[MIT](https://choosealicense.com/licenses/mit/)