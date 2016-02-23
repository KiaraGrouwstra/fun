defmodule Fun do

  @doc """
      currying, by [Patrik Storm](http://blog.patrikstorm.com/function-currying-in-elixir)
      iex> curried = curry(&Kernel.+/2)
      iex> plus5 = curried.(5)
      iex> plus5.(3)
      8
  """
  def curry(fun) do
    {_, arity} = :erlang.fun_info(fun, :arity)
    curry(fun, arity, [])
  end

  defp curry(fun, 0, arguments) do
    apply(fun, Enum.reverse arguments)
  end

  defp curry(fun, arity, arguments) do
    fn arg -> curry(fun, arity - 1, [arg | arguments]) end
  end

  @doc """
      iex> arity(&Kernel.even?/1)
      1
      iex> arity(&Kernel.+/2)
      2
  """
  def arity(fun) do
    case :erlang.fun_info(fun, :arity) do
      { :arity, arity } ->
        arity
    end
  end

  @doc """
     iex> myfun = fn(args) -> args end
     iex> myfun3 = adapt!(myfun, 3)
     iex> myfun3.(:a, :b, :c)
     [:a, :b, :c]
     iex> myfun2 = adapt!(myfun, 2)
     iex> myfun2.(:x, :y)
     [:x, :y]
  """
  def adapt!(fun, 0) do
    fn -> fun.([]) end
  end

  # the max number of arguments for anonymous functions is 20
  Enum.reduce 1 .. 20, [], fn i, args ->
    args = [{ :"arg#{i}", [], nil } | args]

    def adapt!(fun, unquote(i)) do
      fn unquote_splicing(args) -> fun.(unquote(args)) end
    end

    args
  end

  defmacro adapt(arity, do: block) do
    quote do
      fn(var!(arguments)) -> unquote(block) end |> adapt!(unquote(arity))
    end
  end

  @doc """
      iex> add2 = partial(&Kernel.+/2, [2])
      iex> add2.(4)
      6
  """
  def partial(fun, partial) do
    adapt arity(fun) - length(partial) do
      fun |> apply(partial ++ arguments)
    end
  end

  @doc """
      iex> not_even = complement(&Integer.even?/1)
      iex> not_even.(2)
      false
      iex> not_even.(3)
      true
  """
  def complement(fun) do
    adapt arity(fun) do
      not apply(fun, arguments)
    end
  end

  @doc """
      iex> negate = lift(&Kernel.-/1)
      iex> neg_add = negate.(&Kernel.+/2)
      iex> neg_add.(2, 2)
      -4
  """
  def lift(modifier) do
    fn base ->
      adapt arity(base) do
        base |> apply(arguments) |> modifier.()
      end
    end
  end

  @doc """
      iex> plus = &Kernel.+/2
      iex> add = &Enum.reduce(&1, plus)
      iex> comp([&Kernel.to_string/1, add]).([8, 8, 8])
      "24"
  """
  def comp(funs) do
    rfuns = funs |> Enum.reverse
    arity = arity(funs |> Enum.at(0))
    rfuns |> Enum.reduce(fn(outer, inner) ->
      fn(args) ->
        outer.(apply(inner, args))
      end |> adapt!(arity(inner))
    end)
  end

  @doc """
      iex> plus = &Kernel.+/2
      iex> add = &Enum.reduce(&1, plus)
      iex> flow([add, &Kernel.to_string/1]).([8, 8, 8])
      "24"
  """
  def flow(funs) do
    arity = arity(funs |> Enum.at(-1))
    funs |> Enum.reduce(fn(outer, inner) ->
      fn(args) ->
        outer.(apply(inner, args))
      end |> adapt!(arity(inner))
    end)
  end

  @doc """
      iex> juxt([&Enum.empty?/1, &Enum.reverse/1, &Enum.count/1]).([:a, :b, :c])
      [false, [:c, :b, :a], 3]
  """
  def juxt(funs) do
    fn arg ->
      funs |> Enum.map(&(&1.(arg)))
    end
  end

  @doc """
      iex> separate([0,1,2,3], &Integer.odd?/1)
      [[1,3], [0,2]]
  """
  def separate(list, pred) do
    juxt([&Enum.filter(&1, pred), &Enum.reject(&1, pred)]).(list)
  end

  @doc """
      iex> eight = always(8, 3)
      iex> eight.(1,2,3)
      8
  """
  def always(value, arity) do
    adapt arity do
      value
    end
  end

end
