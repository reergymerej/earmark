defmodule Support.AstHelpers do
  
  def ast_from_md(md) do
    with {:ok, ast, []} <- Earmark.as_ast(md), do: ast
  end

  def ast(content)
  def ast(content) when is_binary(content), do: [content]
  def ast(content) when is_tuple(content), do: _ast([content], [])
  def ast(content) when is_atom(content), do: {to_string(content), [], []} 
  def ast(content), do: _ast(content, [])

  def ast!(content, messages\\[])
  def ast!(content, []), do: {:ok, ast(content), []}
  def ast!(content, messages), do: {:error, ast(content), messages}

  def para(atts_or_content, content \\ nil)
  def para(content, nil), do: ast([{:p, [], content}])
  def para(atts, content), do: ast([{:p, atts, content}])

  def para!(atts_or_content, content \\ nil, messages \\ [])
  def para!(content, nil, messages), do: ast!([{:p, [],content}], messages)
  def para!(atts, content, messages), do: ast!([{:p, atts, content}], messages)

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
  defp _ast([node|rest], result), do: _ast(rest, [_tuple(node)|result])

  defp _tuple(tuple)
  defp _tuple({h, e}), do: _tuple({h, [], e})
  defp _tuple({h, a, e}) when is_tuple(a), do: {to_string(h), _atts(a), ast(e)}
  defp _tuple({h, a, e}), do: {to_string(h), _atts(a), ast(e)}
  defp _tuple(x) when is_atom(x), do: {to_string(x), [], []}
  defp _tuple(x), do: to_string(x)

  defp _atts(atts)
  defp _atts(atts) when is_list(atts), do: atts |> Enum.map(&_att/1)
  defp _atts(atts), do: [_att(atts)]

  defp _att({k,v}), do: {to_string(k), to_string(v)}

end
