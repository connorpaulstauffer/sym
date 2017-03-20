defmodule Sym.Law do
  
  @laws [
    :identity, 
    :universal_bound,
    :double_negation, 
    :tautology,
    :contradiction,
    :idempotent, 
    :biconditional, 
    :negated_conditionals, 
    :negated_conditional, 
    :conditional, 
    :rev_demorgan, 
    :rev_distributive
  ]
  
  def laws, do: @laws
  
  # p ∨ c ≡ p
  def identity({ :||, [p, :C] }), do: p
  def identity({ :||, [:C, p] }), do: p
  # p ∧ t ≡ p
  def identity({ :&, [p, :T] }), do: p
  def identity({ :&, [:T, p] }), do: p
  def identity(p), do: p
  
  # p ∨ t ≡ t
  def universal_bound({ :||, [_, :T] }), do: :T
  def universal_bound({ :||, [:T, _] }), do: :T
  # p ∧ c ≡ c
  def universal_bound({ :&, [_, :C] }), do: :C
  def universal_bound({ :&, [:C, _] }), do: :C
  def universal_bound(p), do: p
  
  # ∼∼p ≡ p
  def double_negation({ :!, { :!, p } }), do: p
  def double_negation(p), do: p
  
  # p ∧ p ≡ p
  def idempotent({ :&, [p, p] }), do: p
  # p ∨ p ≡ p
  def idempotent({ :||, [p, p] }), do: p
  def idempotent(p), do: p
  
  #  p ↔ q ≡ (p → q) ∧ (q → p)
  def biconditional({ :<>, [p, q] }), do: 
    { :&, [{ :->, [p, q] }, { :->, [p, q] }] }
  def biconditional(p), do: p
  
  # ∼p → ∼q ≡ q -> p
  def negated_conditionals({ :->, [{ :!, p }, { :!, q }] }), do: { :->, [q, p] }
  def negated_conditionals(p), do: p
  
  # ∼(p → q) ≡ p ∧ ∼q
  def negated_conditional({ :!, { :->, [p, q] } }), do: { :&, [p, { :!, q }] }
  def negated_conditional(p), do: p
  
  def conditional({ :->, [p, q] }), do: { :||, [{ :!, p }, q] }
  def conditional(p), do: p
  
  # ∼(p ∨ q) ≡ ∼p ∧ ∼q
  def demorgan({ :!, { :||, [p, q] } }), do: { :&, [{ :!, p }, { :!, q }] }
  # ∼(p ∧ q) ≡ ∼p ∨ ∼q
  def demorgan({ :!, { :&, [p, q] } }), do: { :||, [{ :!, p }, { :!, q }] }
  def demorgan(p), do: p
  
  def rev_demorgan({ :&, [{ :!, p }, { :!, q }] }), do: { :!, { :||, [p, q] } }
  def rev_demorgan({ :||, [{ :!, p }, { :!, q }] }), do: { :!, { :&, [p, q] } }
  def rev_demorgan(p), do: p
  
  # (p ∧ q) ∨ (p ∧ r) ≡ p ∧ (q ∨ r)
  def rev_distributive({ :||, [{ :&, [p, q] }, { :&, [p, r] }] }), do:
    { :&, [p, { :||, [q, r] } ] }
  # (p ∨ q) ∧ (p ∨ r) ≡ p ∨ (q ∧ r)
  def rev_distributive({ :&, [{ :||, [p, q] }, { :||, [p, r] }] }), do:
    { :||, [p, { :&, [q, r] } ] }
  def rev_distributive(p), do: p
  
  def tautology({ :||, [p, { :!, p }] }), do: :T
  def tautology({ :||, [{ :!, p }, p] }), do: :T
  def tautology(p), do: p
  
  def contradiction({ :&, [p, { :!, p }] }), do: :C
  def contradiction({ :&, [{ :!, p }, p] }), do: :C
  def contradiction(p), do: p
    
end