defmodule Sym do 
  
  @operators [:~, :&, :|, :->, :<->]
  
  # p ∨ c ≡ p
  def identity({ :|, [p, :c] }), do: p
  # def identity({ :|, [:c, p] }), do: p
  # p ∧ t ≡ p
  def identity({ :&, [p, :t] }), do: p
  # def identity({ :&, [:t, p] }), do: p
  def identity(p), do: p
  
  # ∼∼p ≡ p
  def double_negation({ :~, { :~, p } }), do: p
  def double_negation(p), do: p
  
  # p ∧ p ≡ p
  def idempotent({ :&, [p, p] }), do: p
  # p ∨ p ≡ p
  def idempotent({ :|, [p, p] }), do: p
  def idempotent(p), do: p
  
  #  p ↔ q ≡ (p → q) ∧ (q → p)
  def biconditional({ :<->, [p, q] }), do: 
    { :&, [{ :->, [p, q] }, { :->, [p, q] }] }
  def biconditional(p), do: p
  
  # ∼p → ∼q ≡ q -> p
  def negated_conditionals({ :->, [{ :~, p }, { :~, q }] }), do: { :->, [q, p] }
  def negated_conditionals(p), do: p
  
  # ∼(p → q) ≡ p ∧ ∼q
  def negated_conditional({ :~, { :->, [p, q] } }), do { :&, [p, { :~, q }] }
  def negated_conditional(p), do: p
  
  def conditional({ :->, [p, q] }), do: { :|, [{ :~, p }, q] }
  def conditional(p), do: p
  
  # ∼(p ∨ q) ≡ ∼p ∧ ∼q
  def demorgan({ :~, { :|, [p, q] } }), do: { :&, [{ :~, p }, { :~, q }] }
  # ∼(p ∧ q) ≡ ∼p ∨ ∼q
  def demorgan({ :~, { :&, [p, q] } }), do: { :|, [{ :~, p }, { :~, q }] }
  def demorgan(p), do: p
  
  # (p ∧ q) ∨ (p ∧ r) ≡ p ∧ (q ∨ r)
  def reverse_distributive({ :|, [{ :&, [p, q] }, { :&, [p, r] }] }), do:
    { :&, [p, { :|, [q, r] } ] }
  # (p ∨ q) ∧ (p ∨ r) ≡ p ∨ (q ∧ r)
  def reverse_distributive({ :&, [{ :|, [p, q] }, { :|, [p, r] }] }), do:
    { :|, [p, { :&, [q, r] } ] }
  def reverse_distributive(p), do: p
  
end

# { :~, { :~, true } }
# { :~, true }
# { :&, [:p, :q] }
# { :|, [:p, :q] }
# { :->, [:p, :q] }


# identity
# double negation
# indempotent
# if only if
# reverse conditional negations
# negated conditional
# conditional def
# demorgan
# reverse distributive

# commutative to order alphabetically

# only used if necessary. not normal simplification
# universal bound
# absorption

# ?
# negation laws
# negation of t and c


# Commutative laws: p ∨ q ≡ q ∨ p p ∧ q ≡ q ∧ p
# Associative laws: (p ∨ q) ∨ r ≡ p ∨ (q ∨ r) (p ∧ q) ∧ r ≡ p ∧ (q ∧ r)
# Distributive laws: p ∧ (q ∨ r) ≡ (p ∧ q) ∨ (p ∧ r) p ∨ (q ∧ r) ≡ (p ∨ q) ∧ (p ∨ r)
# Idempotent laws: p ∨ p ≡ p p ∧ p ≡ p
# Absorption laws: p ∧ (p ∨ q) ≡ p p ∨ (p ∧ q) ≡ p
# Identity laws: p ∨ c ≡ p p ∧ t ≡ p
# Universal bound laws: p ∨ t ≡ t p ∧ c ≡ c
# De Morgan laws: ∼(p ∨ q) ≡ ∼p ∧ ∼q ∼(p ∧ q) ≡ ∼p ∨ ∼q
# Negation laws: p ∨ ∼p ≡ t p ∧ ∼p ≡ c
# Negations of t and c: ∼t ≡ c ∼c ≡ t
# Double negation law: ∼∼p ≡ p
# Other equivalences: p → q ≡ ∼p ∨ q ∼(p → q) ≡ p ∧ ∼q
# p → q ≡ ∼q → ∼p p ↔ q ≡ (p → q) ∧ (q → p)