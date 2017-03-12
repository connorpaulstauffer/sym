defmodule Sym do 
  
  require IEx
  
  @op_strs %{ :! => "~", :& => "&", :|| => "v", :-> => "->", :<> => "<->" }
  @op_syms @op_strs 
    |> Map.keys 
    |> Enum.map(fn k -> { @op_strs[k], k } end) 
    |> Enum.into(%{})
    
  @laws [
    :identity, 
    :double_negation, 
    :idempotent, 
    :biconditional, 
    :negated_conditionals, 
    :negated_conditional, 
    :conditional, 
    :demorgan, 
    :reverse_distributive
  ]
  
  # p ∨ c ≡ p
  def identity({ :||, [p, :c] }), do: p
  # def identity({ :||, [:c, p] }), do: p
  # p ∧ t ≡ p
  def identity({ :&, [p, :t] }), do: p
  # def identity({ :&, [:t, p] }), do: p
  def identity(p), do: p
  
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
  
  # (p ∧ q) ∨ (p ∧ r) ≡ p ∧ (q ∨ r)
  def reverse_distributive({ :||, [{ :&, [p, q] }, { :&, [p, r] }] }), do:
    { :&, [p, { :||, [q, r] } ] }
  # (p ∨ q) ∧ (p ∨ r) ≡ p ∨ (q ∧ r)
  def reverse_distributive({ :&, [{ :||, [p, q] }, { :||, [p, r] }] }), do:
    { :||, [p, { :&, [q, r] } ] }
  def reverse_distributive(p), do: p
  
  def to_s(p), do: _to_s(p) |> String.replace(~r/^\(|\)$/, "")

  def _to_s({ :!, p }), do: "#{op_to_s(:!)}#{ _to_s(p) }"
  def _to_s({ op, [p, q] }), do: "(#{_to_s(p)} #{op_to_s(op)} #{_to_s(q)})"
  def _to_s(p), do: "#{p}"
  
  def op_to_s(op), do: @op_strs[op]
  def op_to_sym(str), do: @op_syms[str]
  
  def simplify(prop), do: @laws |> Enum.reduce(prop, &apply(Sym, &1, [&2]))
  
  defmodule Parser do
        
    use Neotomex.ExGrammar
    
    @root true
    define :proposition, 
      "(expression / negated / wrapped / atom)"
      
    define :wrapped, "<'('> (expression / negated / atom) <')'>", do: ([p] -> p)

    define :expression, 
      "(wrapped / negated / atom) 
      <space?> 
      (conjunctive / disjunctive / conditional / biconditional) 
      <space?> 
      (wrapped / negated / atom)", 
      do: ([p, op, q] -> { op, [p, q] })
    
    define :negated, "negation (atom / wrapped)", do: ([:!, p] -> { :!, p })
    
    define :conjunctive, "[\&]", do: (op -> Sym.op_to_sym(op))
    define :negation, "'~'", do: (op -> Sym.op_to_sym(op))
    define :disjunctive, "'v'", do: (op -> Sym.op_to_sym(op))
    define :conditional, "'->'", do: (op -> Sym.op_to_sym(op))
    define :biconditional, "'<->'", do: (op -> Sym.op_to_sym(op))
    
    define :atom, "[a-z]", do: (p -> String.to_atom(p))
    
    define :space, "[ \\r\\n\\s\\t]*"
    
    def parse_prop(prop) do
      { :ok, p } = parse(prop)
      p
    end
    
  end
  
end

# { :!, { :!, true } }
# { :!, true }
# { :&, [:p, :q] }
# { :||, [:p, :q] }
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

# (p ∧ ∼p) → (p ∨ (q ∨ p))
# { :->, [{ :&, [:p, { :!, :p }] }, { :||, [:p, { :||, [:q, :p] }] }] }

