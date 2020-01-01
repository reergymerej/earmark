defmodule Earmark.CLI do

  # used to document a module, or not, in this case
  # https://hexdocs.pm/elixir/writing-documentation.html#module-attributes
  @moduledoc false

  # Entry point for escript.
  # https://hexdocs.pm/mix/master/Mix.Tasks.Escript.Build.html
  # Escripts can be installed with mix escript.install.
  # https://hexdocs.pm/mix/master/Mix.Tasks.Escript.Install.html#content
  # They can be run with /Users/jeremygreer/.mix/escripts/earmark --help.
  def main(argv) do

    # Pipes argv into each function.
    # https://elixirschool.com/en/lessons/basics/pipe-operator/
    argv
    |> parse_args
    |> process
  end

  @args """
  usage:

     earmark --help
     earmark --version
     earmark [ options... <file> ]

  convert file from Markdown to HTML.

     where options can be any of:
       --code-class-prefix <a prefix>
       --gfm
       --smartypants
       --pedantic
       --pure-links
       --breaks
       --timeout <timeout in ms>

  """

  @cli_options [:code_class_prefix, :gfm, :smartypants, :pedantic, :pure_links, :breaks, :timeout]

  # private module
  defp parse_args(argv) do
    # create a keyword list
    switches = [
      help: :boolean,
      version: :boolean
      ]
    # create a keyword list
    aliases = [
      h: :help,
      v: :version
    ]

    # The result of parse_args/1 is the result of this case.
    # https://elixir-lang.org/getting-started/case-cond-and-if.html
    # Evaluate OptionParser.parse(argv, opts \\ [])
    # https://hexdocs.pm/elixir/OptionParser.html#parse/2
    # OptionParser is built in.

    # It looks like this gets 3 args, but it only gets two.
    # > In general, when the keyword list is the last argument of a function,
    # > the square brackets are optional.
    case OptionParser.parse(argv, switches: switches, aliases: aliases) do
      # { parsed, args, invalid }
      # parsed = [{switch_name: value}]
      # We use pattern matching to see if there was a single option from
      # "switches" turned on.  If so, the kwl here will have the switch_name as
      # an atom and a bool true.  We don't care about the other values.
      # "switch" gets the value of the atom and is returned.
      { [ {switch, true } ],  _, _ } -> switch

      # The result is a keyword list of options, assigned "options" and a list
      # of _other_ values not in our known switches, with a single value.  The
      # single value is assigned "filename".
      # OptionParser.parse(
      #   ["--help", "--no-bork", "otherstuff"],
      #   switches: [help: :boolean, bork: :boolean]
      # )
      # {[help: true, bork: false], ["otherstuff"], []}
      # From here, we return a tuple of 3, with the result of open_file.
      { options, [ filename ],  _ }  -> {open_file(filename), filename, options}

      { options, [ ],           _ }  -> {:stdio, "<no file>", options}
      _                              -> :help
    end
  end


  defp process(:help) do
    IO.puts(:stderr, @args)
    IO.puts(:stderr, option_related_help())
  end

  defp process(:version) do
    IO.puts( Earmark.version() )
  end

  defp process({io_device, filename, options}) do
    options = struct(Earmark.Options,
                 booleanify(options) |> numberize_options([:timeout]) |> add_filename(filename))

    content = IO.stream(io_device, :line) |> Enum.to_list
    Earmark.as_html!(content, options)
    |> IO.puts
  end

  defp add_filename(options, filename),
    do: [{:file, filename} | options]


  defp booleanify( keywords ), do: Enum.map(keywords, &booleanify_option/1)
  defp booleanify_option({k, v}) do
    {k,
     case Map.get %Earmark.Options{}, k, :does_not_exist do
        true  -> if v == "false", do: false, else: true
        false -> if v == "false", do: false, else: true
        :does_not_exist ->
          IO.puts( :stderr, "ignoring unsupported option #{inspect k}")
          v
        _     -> v
      end
    }
  end

  defp numberize_options(keywords, option_names), do: Enum.map(keywords, &numberize_option(&1, option_names))
  defp numberize_option({k, v}, option_names) do
    if Enum.member?(option_names, k) do
      case Integer.parse(v) do
        {int_val, ""}   -> {k, int_val}
        {int_val, rest} -> IO.puts(:stderr, "Warning, non numerical suffix in option #{k} ignored (#{inspect rest})")
                           {k, int_val}
        :error          -> IO.puts(:stderr, "ERROR, non numerical value #{v} for option #{k} ignored, value is set to nil")
                           {k, nil}
      end
    else
      {k, v}
    end
  end

  # Private module, defined in one line.  Doesn't use do/end block.
  # https://elixir-lang.org/getting-started/case-cond-and-if.html#doend-blocks
  # File.open/2
  # https://hexdocs.pm/elixir/File.html#open/2
  # Open the file and pass the result tuple to io_device, along with the
  # filename.
  defp open_file(filename), do: io_device(File.open(filename, [:utf8]), filename)

  # This is handling for the various outcomes of opening the file.
  # OK with an io_device.
  # An io_device is a type defined by the File module.
  # https://hexdocs.pm/elixir/File.html#t:io_device/0
  # https://elixir-lang.org/getting-started/typespecs-and-behaviours.html#defining-custom-types
  # In this case, just return the io_device.  We don't care what filename this
  # was called with.
  defp io_device({:ok, io_device}, _), do: io_device

  # Here, File.open failed with the :error atm.  Extract the reason and filename
  # with pattern matching.
  # The first arg, the tuple, is provided by the call to File.open.  The
  # filename was included above after the result to File.open.
  defp io_device({:error, reason}, filename) do
    # https://hexdocs.pm/elixir/IO.html#puts/2
    # By default, this writes to :stdio.  Here we tell it to use :stderr.
    # The 2nd param is an interpolated BitString.
    # https://elixir-lang.org/getting-started/basic-types.html#strings

    # :file.format_error/1 is a call to the underlying Erlang, used to make a
    # pretty error message.
    # http://erlang.org/doc/man/file.html#format_error-1
    IO.puts(:stderr, "#{filename}: #{:file.format_error(reason)}")

    # exit abnormally
    # https://hexdocs.pm/elixir/Kernel.html#exit/1
    exit(1)
  end

  defp option_related_help do
    @cli_options
    |> Enum.map(&specific_option_help/1)
    |> Enum.join("\n")
  end

  defp specific_option_help(option) do
    "      --#{unixize_option(option)} defaults to #{inspect(Map.get(%Earmark.Options{}, option))}"
  end

  defp unixize_option(option) do
    "#{option}"
    |> String.replace("_", "-")
  end

end

# SPDX-License-Identifier: Apache-2.0
