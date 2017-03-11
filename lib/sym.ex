defmodule Sym do 
  
  @operators [:~, :&, :|, :->, :<->]
  
  def double_negation({ :~, { :~, p } }), do: p
  def double_negation(p), do: p
  
  def idempotent({ :&, [p, p] }), do: p
  def idempotent({ :|, [p, p] }), do: p
  def idempotent(p), do: p
  
  def biconditional({ :<->, [p, q] }), do: 
    { :&, [{ :->, [p, q] }, { :->, [p, q] }] }
  def biconditional(p), do: p
  
  
  
end

# { :~, { :~, true } }
# { :~, true }
# { :&, [:p, :q] }
# { :|, [:p, :q] }
# { :->, [:p, :q] }


# double negation
# indempotent
# if only if
# reverse conditional negations
# negated conditional
# conditional def
# reverse demorgan
# reverse distributive
# associative to remove parens
# commutative to order alphabetically

# only used if necessary. not normal simplification
# identity
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