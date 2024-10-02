defprotocol Monex.Eq do
  @fallback_to_any true

  def equals?(a, b)
end

defimpl Monex.Eq, for: Any do
  def equals?(a, b) do
    a == b
  end
end
