defmodule Acceptance.Ast.GfmLists.ListTest do
  use ExUnit.Case
  import Support.AstHelpers


  describe "What are lists?" do
    test "GFM Spec #231" do
      markdown = """
      A paragraph
      with two lines.

          indented code

      > A block quote.
      """
      expected = [
        {"p", [], ["A paragraph\nwith two lines."]},
        {"pre", [], [{"code", [], ["indented code"]}]},
        {"blockquote", [], [{"p", [], ["A block quote."]}]}
      ]


      assert ast_from_md(markdown) == expected
    end
  end
  describe "Lists can interrupt paragraphs" do
    test "GFM Spec #283" do
      markdown = """
      Foo
      - bar
      - baz
      """
      expected = [{"p", [], ["Foo"]}, {"ul", [], [{"li", [], ["bar"]}, {"li", [], ["baz"]}]}]

      assert ast_from_md(markdown) == expected
    end
  end
end
