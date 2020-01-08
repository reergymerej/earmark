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
    # The result of parse_args will either be
    # a single flag as an atom
    # {file, filename, options},
    # {:stdio, "<no file>", options},
    # or :help.
    |> parse_args
    # Call "process", with (argv, ...parse_args result)
    |> process
  end

  # This is a module attribute used to print help info.
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

  # List of atoms used for command line options
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
      # {io_device, filename, options} are returned here if all went well.
      { options, [ filename ],  _ }  -> {open_file(filename), filename, options}

      # Args were parsed and there was nothing extra seen as filename.  In this
      # case, we return {:stdio, fake file name, options}
      { options, [ ],           _ }  -> {:stdio, "<no file>", options}

      # By default, just return an atom :help.
      _                              -> :help
    end
  end


  # When called with the :help atom
  defp process(:help) do
    # Put to :stderr the module attribute @args.
    IO.puts(:stderr, @args)
    # Also put to :stderr the result of option_related_help
    IO.puts(:stderr, option_related_help())
  end

  # When process is passed the :version atom...
  defp process(:version) do
    # Print the result of Earmark.version()
    # lib/earmark.ex
    IO.puts( Earmark.version() )
  end

  # process may also get this tuple.  This is not obvious, since the results
  # come indirectly from parse_args.
  defp process({io_device, filename, options}) do
    # match operator binds to "options"
    #
    # struct updates a struct
    # https://hexdocs.pm/elixir/Kernel.html#struct/2
    #
    # Earmark.Options is our base struct
    # lib/earmark/options.ex
    #
    # Get the list of fields - two-element tuples (key-value pairs) - to update
    # the base struct will come from this chain
    #   booleanify
    #   numberize_options
    #   add_filename
    options = struct(Earmark.Options,
      booleanify(options) |> numberize_options([:timeout]) |> add_filename(filename))

    content = IO.stream(io_device, :line) |> Enum.to_list
    Earmark.as_html!(content, options)
    |> IO.puts
  end

  defp add_filename(options, filename),
  do: [{:file, filename} | options]


  # for each keyword, replace with the result of running it through booleanify_option
  # https://hexdocs.pm/elixir/Enum.html#map/2
  # Use the capture operator to avoid defining this inline
  defp booleanify( keywords ), do: Enum.map(keywords, &booleanify_option/1)

  # for a 2-element tuple
  # assign k and v
  # return another 2-element tuple
  defp booleanify_option({k, v}) do

    # don't mess with k
    {k,

    # Pull value k from the options struct, default atom :does_not_exist.
    # https://hexdocs.pm/elixir/Map.html#get/3
    # lib/earmark/options.ex

    # omitting optional ()
    # This does not seem to be typical.
    # https://github.com/christopheradams/elixir_style_guide#parentheses
      case Map.get %Earmark.Options{}, k, :does_not_exist do

         # If the value was found, return the v value as a boolean.
        true  -> if v == "false", do: false, else: true
        false -> if v == "false", do: false, else: true

        # If not found,
        :does_not_exist ->
         # log a warning
          IO.puts( :stderr, "ignoring unsupported option #{inspect k}")
         # return the original v
          v

       # The option was found but not true/false.
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
  # If this fails, the process ends.  Otherwise, we get the io_device.
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

  # private module
  defp option_related_help do

    # module attribute
    @cli_options

    # pipe list of atoms into Enum.map
    # https://hexdocs.pm/elixir/Enum.html#map/2
    # The 2nd param to Enum.map/2 is a function to run on each item in the
    # enumerable.  This uses the capture operator, &, to refer to the
    # specific_option_help/1 function of this module.
    # https://elixir-lang.org/getting-started/modules-and-functions.html#function-capturing
    |> Enum.map(&specific_option_help/1)
    # Joins each enumerable, in this case, the line of text describing option,
    # with a newline.
    # https://hexdocs.pm/elixir/Enum.html#join/2
    |> Enum.join("\n")
  end

  # private function, returns a string
  defp specific_option_help(option) do
    # unixize_option converts atom to CLI option string
    # %Earmark.Options{} is a Struct.  Structs are like Maps, but with compile
    # time type checking and default values.
    # https://hexdocs.pm/elixir/Kernel.SpecialForms.html#%2525/2
    # lib/earmark/options.ex
    #
    # Structs can be used as Maps because they're just fancier Maps.
    # https://elixir-lang.org/getting-started/structs.html#structs-are-bare-maps-underneath
    # %Earmark.Options{} returns the Struct.  Them Map.get/3 pulls the option.
    #
    # Map.get/3 gets the value for a key in a map.
    # https://hexdocs.pm/elixir/Map.html#get/3
    # The 3rd param is optional and excluded here.
    #
    # inspect stringifies an element.
    # https://hexdocs.pm/elixir/Inspect.html
    #
    # Altogether, this shows the option with - instead of _ and prints the
    # pretty default based on the %Earmark.Options{} struct's defaults.
    "      --#{unixize_option(option)} defaults to #{inspect(Map.get(%Earmark.Options{}, option))}"
      end

      defp unixize_option(option) do
    # Takes an option (atom), turns it into a string...
      "#{option}"
    # pipes that into String.replace/4 skipping optional options.
    # https://hexdocs.pm/elixir/String.html#replace/4
    # Returns the atom as a string with s/_/-
    # We keep the options stored as atoms.  Atoms can't have hyphens.
    # > Elixir converts switches to underscored atoms, so --source-path becomes
    # > :source_path.
    |> String.replace("_", "-")
      end

      end

# SPDX-License-Identifier: Apache-2.0
