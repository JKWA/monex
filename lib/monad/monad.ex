defprotocol Monex.Monad do
  @type t() :: term()

  @spec ap(t(), t()) :: t()
  def ap(func, m)

  @spec bind(t(), (term() -> t())) :: t()
  def bind(m, func)

  @spec map(t(), (term() -> term())) :: t()
  def map(m, func)
end
