defmodule Sym.Proposition.Connective do 
  
  # @binding_order [&negation/1, &disjunction/2, &conjunction/2, &implication/2]
  
  def negation(true), do: false
  def negation(false), do: true
    
  def disjunction(true, _), do: true
  def disjunction(_, true), do: true
  def disjunction(false, false), do: false
  
  def conjunction(true, true), do: true
  def conjunction(false, _), do: false
  def conjunction(_, false), do: false
  
  def implication(p, q), do: disjunction(negation(p), q)
  
end