# define a module
defmodule Earmark.Types do

  # skip docs
  @moduledoc false

  # Here we define a macro.
  # __using__/1 is where we inject code into the module that called
  # `use Earmark.Types`
  # https://elixirschool.com/en/lessons/basics/modules/#use
  # This basically makes some basic types available to whatever module uses it.
  defmacro __using__(_options \\ []) do
    # quote returns the representation of an expression
    # https://elixir-lang.org/getting-started/meta/quote-and-unquote.html#quoting
    quote do

      # Thesa are type definitions that will be injected into the using module.
      # https://hexdocs.pm/elixir/typespecs.html
      # Typespecs are useful for humans and tools, but are ignored by the
      # compiler since Elixir is dynamically typed.

      # token is a tuple with an atom and a String.t
      # iex> t String.t
      # shows info about this type.  It's a UTF-8 encoded binary.
      @type token  :: {atom, String.t}

      # tokens is a list of token
      # https://hexdocs.pm/elixir/typespecs.html#basic-types
      @type tokens :: list(token)

      # Defines a map with two required and one optional key/value pairs.
      @type numbered_line :: %{
        # must have :line key in Map and value with String.t type
        required(:line) => String.t,
        # must have :lng key with a number
        required(:lnb) => number,
        # the map may have a key :inside_code with a String.t value
        optional(:inside_code) => String.t
      }

      # :warning or :error are both considered message_type
      @type message_type :: :warning | :error

      # a tuple with a message_type, number, and a UTF-8 string
      @type message :: {message_type, number, String.t}

      # parameterized type
      # https://hexdocs.pm/elixir/typespecs.html#types-and-their-syntax
      # maybe(t) is something with a t, any type, or nil
      # You can see this used in the using module,
      # lib/earmark/options.ex
      # t is actually defined in the using module, lib/earmark/options.ex
      @type maybe(t) :: t | nil

      # a tuple with nil or a string, then a number
      @type inline_code_continuation :: {nil | String.t, number}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
