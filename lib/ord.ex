defprotocol Monex.Ord do
  @fallback_to_any true

  def lt?(a, b)
  def le?(a, b)
  def gt?(a, b)
  def ge?(a, b)
end

defimpl Monex.Ord, for: Any do
  def lt?(a, b), do: a < b
  def le?(a, b), do: a <= b
  def gt?(a, b), do: a > b
  def ge?(a, b), do: a >= b
end

# def contramap(ord, f) do
#   %{
#     lt?: fn a, b -> ord.lt?(f.(a), f.(b)) end,
#     le?: fn a, b -> ord.le?(f.(a), f.(b)) end,
#     gt?: fn a, b -> ord.gt?(f.(a), f.(b)) end,
#     ge?: fn a, b -> ord.ge?(f.(a), f.(b)) end
#   }
# end
