defmodule Sym.Proposition.Expression do
  
  alias Sym.Proposition.Connective
  
  def apply_commutative({ con, [p, q] }), do: [{ con, [q, p] }]
  
end