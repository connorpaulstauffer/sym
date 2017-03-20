defmodule Sym.Parser do
      
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