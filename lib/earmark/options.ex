# define a module
defmodule Earmark.Options do

  # use Earmark.Types, allowing it to inject code into this module
  # lib/earmark/types.ex
  use Earmark.Types

  # What we use to render
  # To define a struct, use defstruct inside the module.
  # https://elixir-lang.org/getting-started/structs.html#defining-structs
  # https://hexdocs.pm/elixir/Kernel.html#defstruct/1
  # defstruct is passed a keyword list that describes the fields and default
  # values.
  # module defined in lib/earmark/html_renderer.ex
  defstruct renderer: Earmark.HtmlRenderer,
            # Inline style options
            gfm: true,
            gfm_tables: false,
            breaks: false,
            pedantic: false,
            smartypants: true,
            footnotes: false,
            footnote_offset: 1,

            # additional prefies for class of code blocks
            code_class_prefix: nil,

            # Add possibility to specify a timeout for Task.await
            timeout: nil,

            # Internal—only override if you're brave
            do_smartypants: nil,

            # Very internal—the callback used to perform
            # parallel rendering. Set to &Enum.map/2
            # to keep processing in process and
            # serial
            # Using the capture operator to reference a named function.
            # defined in lib/earmark.ex
            mapper: &Earmark.pmap/2,
            mapper_with_timeout: &Earmark.pmap/3,
            # lib/earmark/html_renderer.ex
            render_code: &Earmark.HtmlRenderer.render_code/1,

            # Filename and initial line number of the markdown block passed in
            # for meaningfull error messages
            file: "<no file>",
            line: 1,
            # [{:error|:warning, lnb, text},...]
            messages: [],
            # an empty map
            plugins: %{},
            pure_links: true

  # type for t
  # This is used in Earmark.Types, though it is defined here.
  # %__MODULE__ returns the current module name as an atom.
  # https://hexdocs.pm/elixir/Kernel.SpecialForms.html?#__MODULE__/0
  # This is a common pattern to define a top-level type for the module.
  # https://stackoverflow.com/a/29978255/1319850
  # This creates %Earmark.Options.t.
  # You can see this by `iex -S mix` and using the type helper.
  # t Earmark.Options
  # It includes these values and those defined in the defstruct above.
  @type t :: %__MODULE__{
        breaks: boolean,
        code_class_prefix: maybe(String.t),
        footnotes: boolean,
        footnote_offset: number,
        gfm: boolean,
        pedantic: boolean,
        pure_links: boolean,
        smartypants: boolean,
        timeout: maybe(number)
  }

  # Skip docs.  This looks to be a way to make a semi-private function.
  # https://hexdocs.pm/elixir/writing-documentation.html#hiding-internal-modules-and-functions
  @doc false
  # Only here we are aware of which mapper function to use!
  # This function is used in places through the Earmark module, but is not
  # available for end users.
  def get_mapper(options) do
    # If options.timeout is truthy...
    # https://hexdocs.pm/elixir/Kernel.html#module-truthy-and-falsy-values
    # if/2 is a macro.  You can pass the condition and clauses.
    # https://github.com/elixir-lang/elixir/blob/v1.9.4/lib/elixir/lib/kernel.ex#L3093
    if options.timeout do
      # capture operator, telling us to use the function in options.mapper_with_timeout
      # Call the function by name with the .
      # https://elixir-lang.org/getting-started/modules-and-functions.html#function-capturing
      # This has the effect of returning from get_mapper a function that will
      # call mapper_with_timeout, relaying the first 2 arguments, and adding the
      # timeout as the third.
      # &1 and &2 do not refer to the args in _this_ function.
      # In JS, it would be something like
      # getMapper = (options) =>
      #   options.timeout
      #     ? (a, b) => mapperWithTimeout(a, b, options.timeout)
      #     : options.mapper
      &options.mapper_with_timeout.(&1, &2, options.timeout)
    else
      # No timeout, just return the wrapper.
      options.mapper
    end
  end

  # no doc, another internal function
  @doc false
  def plugin_for_prefix(options, plugin_name) do
    # https://hexdocs.pm/elixir/Map.html#get/3
    Map.get(options.plugins, plugin_name, false)
  end
end

# SPDX-License-Identifier: Apache-2.0
