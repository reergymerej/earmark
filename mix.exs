# The mix file is where everything begins.
# https://hexdocs.pm/mix/Mix.html

# defmodule is a macro used to define a new module
# https://elixir-lang.org/getting-started/modules-and-functions.html

# do/end blocks are sugar built on keywords
# https://elixir-lang.org/getting-started/case-cond-and-if.html#doend-blocks
# https://elixir-lang.org/getting-started/keywords-and-maps.html
defmodule Earmark.Mixfile do

  # https://elixir-lang.org/getting-started/alias-require-and-import.html#use
  # Allow Mix.Project to inject code into this module, used for extension.
  # https://hexdocs.pm/mix/Mix.Project.html
  use Mix.Project

  # These are module attributes.  Some are reserved for special usage, like
  # @doc.  These are basically constants used across the module.
  # https://elixir-lang.org/getting-started/module-attributes.html
  @version "1.4.4"
  @url "https://github.com/pragdave/earmark"


  # This is a list of dependencies.
  # https://hexdocs.pm/elixir/List.html
  # https://hexdocs.pm/mix/Mix.html#module-dependencies
  # Each item is a Tuple.
  # https://hexdocs.pm/elixir/Tuple.html
  # `mix help deps` will show info about dependencies in Mix.  There are
  # different formats.
  @deps [
    # {:credo, "~> 0.10", only: [:dev, :test]},
    # {:dialyxir, "~> 0.5", only: [:dev, :test]}
    # {app, requirement, opts}
    {:benchfella, "~> 0.3.0", only: [:dev]},
    {:excoveralls, "~> 0.11.2", only: [:test]},
    {:floki, "~> 0.21", only: [:dev, :test]},
  ]

  # These are heredoc sigils.  Heredocs are multiline strings.  They allow you
  # to avoid escaping characters.  Sigils are a mechanism in Elixir that allows
  # the language to be extended.
  # ~r regex
  # ~s string
  # ~c charlist
  # ~T time
  # https://elixir-lang.org/getting-started/sigils.html#interpolation-and-escaping-in-string-sigils
  @description """
  Earmark is a pure-Elixir Markdown converter.

  It is intended to be used as a library (just call Earmark.as_html),
  but can also be used as a command-line tool (run mix escript.build
  first).

  Output generation is pluggable.
  """

  ############################################################

  # Defines a named function in a module.
  # https://hexdocs.pm/elixir/Kernel.html?#def/2
  def project do

    # :hello is an Atom
    # https://elixir-lang.org/getting-started/basic-types.html#atoms
    # {:hello, :dude} is a Tuple with two Atoms
    # {:hello, "banana"} is a Tuple with an Atom and a BitString
    #
    # A keyword list is a list of two-element tuples, where the first elements
    # are atoms.
    # There's a special syntax for keyword lists.
    # [hello: :dude, hello: "banana"] == [{:hello, :dude}, {:hello, "banana"}]
    #
    # A keyword list is returned with configuration info for Mix.
    # https://hexdocs.pm/mix/Mix.Project.html#module-configuration
    # The values vary a lot and may be determined by various Mix tasks that will
    # run.
    [
      # Keys do not need to be unique in keyword lists.
      app: :earmark,

      # Uses the module attribute to kep it DRY.
      version: @version,

      # Versions are parsed with this.
      # https://hexdocs.pm/elixir/Version.html
      elixir: "~> 1.7",

      # https://hexdocs.pm/mix/Mix.Tasks.Compile.Elixir.html#module-configuration
      # location of source files
      # This calls a helper function with the value of the current Mix
      # environment.
      # https://hexdocs.pm/mix/Mix.html#env/0
      elixirc_paths: elixirc_paths(Mix.env()),

      # https://hexdocs.pm/mix/master/Mix.Tasks.Escript.Build.html
      # Builds an escript.  Escripts can be run on any machine (with Erlang/OTP)
      # from the command line.
      escript: escript_config(),

      # Uses the module attribute to kep it DRY.
      deps: @deps,

      # Uses the module attribute to kep it DRY.
      description: @description,
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls],
      aliases: [docs: &build_docs/1, readme: &readme/1]
    ]
  end

  def application do
    [
      applications: []
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "src/*.xrl",
        "src/*.yrl",
        "mix.exs",
        "README.md"
      ],
      maintainers: [
        "Robert Dober <robert.dober@gmail.com>",
        "Dave Thomas <dave@pragdave.me>"
      ],
      licenses: [
        "Apache 2 (see the file LICENSE for details)"
      ],
      links: %{
        "GitHub" => "https://github.com/pragdave/earmark"
      }
    ]
  end

  defp escript_config do
    # Earmark.CLI is the main module when this is invoked by the CLI.
    # It will enter at main/1.
    # lib/earmark/cli.ex
    [main_module: Earmark.CLI]
  end

  # Private function definitions
  # https://hexdocs.pm/elixir/Kernel.html#defp/2
  # Functions are described with arity, like elixirc_paths/0.
  # These have the same arity, so pattern matching is used to figure out which
  # one is executed.
  # https://elixirschool.com/en/lessons/basics/functions/#functions-and-pattern-matching

  # When called with :test, return this list of BitStrings.  This is where we
  # find source in :test mode.
  defp elixirc_paths(:test), do: ["lib", "test/support", "dev"]

  # Look for source in lib, bench, and dev dirs in :dev mode.
  defp elixirc_paths(:dev), do: ["lib", "bench", "dev"]

  # By default, look for source in lib.
  # _ means we don't care what this value is.  If the function was called with
  # any value, return this list.  Keep in mind that pattern matching happens
  # from top to bottom, so the value was not :test or :dev.
  defp elixirc_paths(_), do: ["lib"]

  @prerequisites """
  run `mix escript.install hex ex_doc` and adjust `PATH` accordingly
  """
  defp build_docs(_) do
    Mix.Task.run("compile")
    ex_doc = Path.join(Mix.Local.path_for(:escript), "ex_doc")
    Mix.shell.info("Using escript: #{ex_doc} to build the docs")

    unless File.exists?(ex_doc) do
      raise "cannot build docs because escript for ex_doc is not installed, make sure to \n#{@prerequisites}"
    end

    args = ["Earmark", @version, Mix.Project.compile_path()]
    opts = ~w[--main Earmark --source-ref v#{@version} --source-url #{@url}]

    Mix.shell.info("Running: #{ex_doc} #{inspect(args ++ opts)}")
    System.cmd(ex_doc, args ++ opts)
    Mix.shell.info("Docs built successfully")
  end

  defp readme(args) do
    Code.load_file("tasks/readme.exs")
    Mix.Tasks.Readme.run(args)
  end
end

# SPDX-License-Identifier: Apache-2.0
