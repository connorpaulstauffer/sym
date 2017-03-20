defmodule Sym do 
  
  alias Sym.Parser
  alias Sym.Law
  
  @op_strs %{ :! => "~", :& => "&", :|| => "v", :-> => "->", :<> => "<->" }
  @op_syms @op_strs 
    |> Map.keys 
    |> Enum.map(fn k -> { @op_strs[k], k } end) 
    |> Enum.into(%{})
  
  
  def to_s({ :!, p }), do: "#{op_to_s(:!)}#{ to_s(p) }"
  def to_s({ op, [p, q] }), do: "(#{to_s(p)} #{op_to_s(op)} #{to_s(q)})"
  def to_s(:T), do: "T"
  def to_s(:C), do: "C"
  def to_s({ p }), do: "#{p}"
  
  def op_to_s(op), do: @op_strs[op]
  def op_to_sym(str), do: @op_syms[str]
  
  def run(str), do: str |> Parser.parse_prop |> simplify |> print
  
  def print({ _, trace }), do:
    trace
      |> Enum.reverse
      |> Enum.map(fn ({ p, law }) -> "#{to_s(p)} -- #{law}" end)
      |> Enum.each(&IO.puts/1)

  def simplify({ :!, p }) do
    { p1, trace_p } = simplify(p)
    { r, trace_r } = apply_laws_rec({ :!, p1 })
    
    { r, trace_r ++ trace_p }
  end
  def simplify({ op, [p, q] }) do
    { p1, trace_p } = simplify(p)
    { q1, trace_q } = simplify(q)
    { r, trace_r } = apply_laws_rec({ op, [p1, q1] })

    { 
      r, 
      trace_r ++ 
      wrap_traces(trace_q, { op, [p1, q] }, q) ++
      wrap_traces(trace_p, { op, [p, q] }, p)
    }
  end 
  def simplify(p), do: apply_laws_rec(p)
  
  def wrap_traces(trace, { op, [p, q] }, p) do
    trace |> Enum.map(fn ({ p1, law }) -> { { op, [p1, q] }, law } end)
  end
  def wrap_traces(trace, { op, [p, q] }, q) do
    trace |> Enum.map(fn ({ q1, law }) -> { { op, [p, q1] }, law } end)
  end
  
  def apply_laws_rec(p), do: apply_laws_rec(p, Law.laws())
  def apply_laws_rec(p, laws), do: combine_traces(apply_laws(p, laws), p, laws)
  
  def combine_traces({ p, trace }, p, _), do: { p, trace }
  def combine_traces({ p1, trace1 }, _, laws) do
    { p2, trace2 } = combine_traces(apply_laws(p1, laws), p1, laws)
    { p2, trace2 ++ trace1 }
  end

  def apply_laws(p, laws) do
    trace = trace_laws(p, laws)
    new_val = if length(trace) == 0, do: p, else: elem(hd(trace), 0)
    { new_val, trace }
  end
  
  def trace_laws(p, laws), do:
    laws 
      |> Enum.scan({ p, nil }, &{ apply(Law, &1, [elem(&2, 0)]), &1 })
      |> Enum.reduce([{ p, nil }], 
        &if(elem(&1, 0) == elem(hd(&2), 0), do: &2, else: [&1 | &2]))
      |> Enum.filter(&(elem(&1, 1) != nil))
  
end