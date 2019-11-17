defmodule Support.AstHelpers do
  
  def ast_from_md(md) do
    with {:ok, ast, []} <- Earmark.as_ast(md), do: ast
  end

  def ast(content)
  def ast(content) when is_tuple(content), do: _ast([content], [])
  def ast(content) when is_atom(content), do: {to_string(content), [], []} 
  def ast(content), do: _ast(content, [])

  def p(content, atts \\ [])
  def p(content, atts) when is_binary(content),
    do: {"p", atts, [content]}
  def p(content, atts),
    do: {"p", atts, content}

  def void_tag(tag, atts \\ []) do
    {to_string(tag), atts, []}
  end


  defp _ast(content, result)
  defp _ast([], result), do: result |> Enum.reverse
  defp _ast([node|rest], result) when is_list(node), do: _ast(result, [ast(node)|result])
  defp _ast([node|rest], result), do: _ast(result, [_tuple(node)|result])

  defp _tuple(tuple)
  defp _tuple({h, e}), do: {to_string(h), [], ast(e)}
  defp _tuple({h, a, e}), do: {to_string(h), a, ast(e)}
  defp _tuple(x), do: to_string(x)


end
