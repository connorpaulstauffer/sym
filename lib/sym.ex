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
  
  @contradiction_seq [
    :identity, 
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
  
  # p ∨ c ≡ p
  def identity({ :||, [p, :C] }), do: p
  # def identity({ :||, [:c, p] }), do: p
  # p ∧ t ≡ p
  def identity({ :&, [p, :T] }), do: p
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
  def tautology(p), do: p
  
  def contradiction({ :&, [p, { :!, p }] }), do: :C
  def contradiction(p), do: p

  def to_s({ :!, p }), do: "#{op_to_s(:!)}#{ to_s(p) }"
  def to_s({ op, [p, q] }), do: "(#{to_s(p)} #{op_to_s(op)} #{to_s(q)})"
  def to_s(:T), do: "T"
  def to_s(:C), do: "C"
  def to_s(p), do: "#{p}"
  
  def op_to_s(op), do: @op_strs[op]
  def op_to_sym(str), do: @op_syms[str]

  def simplify({ :!, p }), do: apply_laws_rec({ :!, simplify(p) })
  def simplify({ op, [p, q] }), do: 
    apply_laws_rec({ op, Enum.map([p, q], &simplify/1) })
  def simplify(p), do: apply_laws_rec(p)
  
  def apply_laws_rec(p), do: apply_laws_rec(p, @laws)
  def apply_laws_rec(p, laws), do: combine_traces(apply_laws(p, laws), p, laws)
  
  def combine_traces({ p, trace }, p, laws), do: { p, trace }
  def combine_traces({ p1, trace1 }, p, laws) do
    { p2, trace2 } = handle_law_trace(apply_laws(p1, laws), p1, laws)
    { p2, trace2 ++ trace1 }
  end

  def apply_laws(p, laws) do
    trace = trace_laws(p, laws)
    new_val = if length(trace) == 0, do: p, else: elem(hd(trace), 0)
    { new_val, trace }
  end
  
  def trace_laws(p, laws), do:
    laws 
      |> Enum.scan({ p, nil }, &{ apply(Sym, &1, [elem(&2, 0)]), &1 })
      |> Enum.reduce([{ p, nil }], 
        &if(elem(&1, 0) == elem(hd(&2), 0), do: &2, else: [&1 | &2]))
      |> Enum.filter(&(elem(&1, 1) != nil))
  
  def laws, do: @laws
  
  defmodule Parser do
        
    use Neotomex.ExGrammar
    
    @root true
    define :proposition, 
      "(expression / negated / wrapped / atom / tautology / contradiction)"
      
    define :wrapped, 
      "<'('> (expression / negated / atom / tautology / contradiction) <')'>", 
      do: ([p] -> p)

    define :expression, 
      "(wrapped / negated / atom) 
      <space?> 
      (conjunctive / disjunctive / conditional / biconditional) 
      <space?> 
      (wrapped / negated / atom)", 
      do: ([p, op, q] -> { op, [p, q] })
    
    define :negated, 
      "negation (atom / wrapped / tautology / contradiction / negated)", 
      do: ([:!, p] -> { :!, p })
    
    define :conjunctive, "[\&]", do: (op -> Sym.op_to_sym(op))
    define :negation, "'~'", do: (op -> Sym.op_to_sym(op))
    define :disjunctive, "'v'", do: (op -> Sym.op_to_sym(op))
    define :conditional, "'->'", do: (op -> Sym.op_to_sym(op))
    define :biconditional, "'<->'", do: (op -> Sym.op_to_sym(op))
    define :tautology, "'T'", do: (_ -> :T)
    define :contradiction, "'C'", do: (_ -> :C)
    
    define :atom, "[a-z]", do: (p -> { String.to_atom(p) })
    
    define :space, "[ \\r\\n\\s\\t]*"
    
    def parse_prop(prop) do
      { :ok, p } = parse(prop)
      p
    end
    
  end
  
end