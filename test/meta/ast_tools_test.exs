defmodule Meta.AstToolsTest do
  use ExUnit.Case
  import Support.AstHelpers

  @moduletag :meta


  describe "cannonical ast creation" do 
    test "simplest case" do
      result = ast([{:p, [], ["hello"]}])
      expect = [{"p", [], ["hello"]}]

      assert result == expect
    end

    test "some children" do
      result = ast([{:p, [], [{:em, [{"a", "b"}], ["x"]}]}])
      expect = [{"p", [], [{"em", [{"a", "b"}], ["x"]}]}]

      assert result == expect
    end
  end

  describe "lists around single elements" do
    test "can be omitted for tuples" do
      result = ast({:p, [], {:em, {"a", "b"}, ["x"]}})
      expect = [{"p", [], [{"em", [{"a", "b"}], ["x"]}]}]

      assert result == expect
    end

    test "can be omitted for strings" do
      result = ast({:p, [], {:em, {"a", "b"}, "x"}})
      expect = [{"p", [], [{"em", [{"a", "b"}], ["x"]}]}]

      assert result == expect
    end
  end

  describe "empty attributes can also be omitted" do
    test "in cannonical case" do
      result = ast([{:p, ["hello"]}])
      expect = [{"p", [], ["hello"]}]

      assert result == expect
    end

    test "together with other simplifications" do
      result = ast({:p, ["x", :a, {:em, "y"}]})
      expect = [{"p", [], ["x", {"a", [], []}, {"em", [], ["y"]}]}]

      assert result == expect
    end
  end
  
  describe "attributes as keyword lists" do
    test "are correctly formatted too" do
      result = ast({:p, [{"data-att", 42}, x: 44], "hello"})
      expect = [{"p", [{"data-att", "42"}, {"x", "44"}], ["hello"]}]

      assert result == expect
    end
  end
  describe "the para shortcut" do
    test "in cannonical case" do
      result = para([], ["hello"])
      expect = [{"p", [], ["hello"]}]

      assert result == expect
    end
    test "omitting the usually empty atts, and using ast's shortcuts" do
      result = para("hello")
      expect = [{"p", [], ["hello"]}]

      assert result == expect
    end
  end

  describe "regressions" do
    test "from img_test" do
      result = para({:img, [src: "url", alt: "foo", title: "title"], []})
      expect = [{"p", [], [{"img", [{"src", "url"}, {"alt", "foo"}, {"title", "title"}], []}]}]

      assert result == expect
    end
  end

  describe "wrapping" do
    test "ast! creates a convenient wrapper" do
      result = ast!({:div, "hello"})
      expect = {:ok, [{"div", [], ["hello"]}], []}

      assert result == expect
    end
    
    test "and so does para!" do
      result = para!([a: 1], {:div, "hello"})
      expect = {:ok, [{"p", [{"a", "1"}], [{"div", [], ["hello"]}]}], []}

      assert result == expect
    end
  end
end
