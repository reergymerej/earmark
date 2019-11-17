defmodule Acceptance.Ast.ListAndBlockTest do
  use ExUnit.Case
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import Support.AstHelpers

  @moduletag :ast

  describe "Block Quotes in Lists" do
    # Incorrect behavior needs to be fixed with #249 or #304
    test "two spaces" do
      markdown = "- a\n  > b"
      html     = "<ul>\n<li>a</li>\n</ul>\n<blockquote><p>b</p>\n</blockquote>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "four spaces" do
      markdown = "- c\n    > d"
      html     = "<ul>\n<li><p>c</p>\n<blockquote><p>d</p>\n</blockquote>\n</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "Void Tags in Lists" do
    test "is part of list" do
      markdown = "- c\n    > d"
      ast      = ast({:ul, {:li, ["a", :br]}}) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
  
end
# SPDX-License-Identifier: Apache-2.0
