defmodule FunTest do
  use ExUnit.Case
  import Fun
  require Integer

  test "curry" do
    curried = curry(&Kernel.+/2)
    plus5 = curried.(5)
    assert plus5.(3) == 8
  end

  test "arity" do
    assert arity(&Integer.is_even/1) == 1
    assert arity(&Kernel.+/2) == 2
  end

  test "adapt!" do
    myfun = fn(args) -> args end
    myfun3 = adapt!(myfun, 3)
    assert myfun3.(:a, :b, :c) == [:a, :b, :c]
    myfun2 = adapt!(myfun, 2)
    assert myfun2.(:x, :y) == [:x, :y]
  end

  test "partial" do
    add2 = partial(&Kernel.+/2, [2])
    assert add2.(4) == 6
  end

  test "complement" do
    not_even = complement(&Integer.is_even/1)
    assert not_even.(2) == false
    assert not_even.(3) == true
  end

  test "lift" do
    negate = lift(&Kernel.-/1)
    neg_add = negate.(&Kernel.+/2)
    assert neg_add.(2, 2) == -4
  end

  test "comp" do
    plus = &Kernel.+/2
    add = &Enum.reduce(&1, plus)
    assert comp([&Kernel.to_string/1, add]).([8, 8, 8]) == "24"
  end

  test "flow" do
    plus = &Kernel.+/2
    add = &Enum.reduce(&1, plus)
    assert flow([add, &Kernel.to_string/1]).([8, 8, 8]) == "24"
  end

  test "juxt" do
    assert juxt([&Enum.empty?/1, &Enum.reverse/1, &Enum.count/1]).([:a, :b, :c]) == [false, [:c, :b, :a], 3]
  end

  test "separate" do
    assert separate([0,1,2,3], &Integer.is_odd/1) == [[1,3], [0,2]]
  end

  test "always" do
    eight = always(8, 3)
    assert eight.(1,2,3) == 8
  end

end
