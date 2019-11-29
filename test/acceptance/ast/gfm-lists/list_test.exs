defmodule Acceptance.Ast.GfmLists.ListTest do
  use ExUnit.Case
  import Support.AstHelpers

  @moduletag :wip

  describe "Lists can interrupt paragraphs" do
    test "GFM Spec #283" do
      markdown = """
      Foo
      - bar
      - baz
      """
      expected = [{"p", [], ["Foo", {"ul", [], [{"li", [], ["bar"]}, {"li", [], ["baz"]}]}]}]

      assert ast_from_md(markdown) == expected
    end
  end
end
