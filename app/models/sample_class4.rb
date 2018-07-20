class SampleClass4

  # https://youtrack.jetbrains.com/issue/RUBY-14677
  def foo(a: nil, b: nil)
    a + b
  end

  def bar
    foo(b: 1)
  end

  # https://youtrack.jetbrains.com/issue/RUBY-14678
  def foo2(a = nil, b = nil)
    puts a + b
  end

  def bar2
    foo2(a = 1, b = 2)
  end

  # https://youtrack.jetbrains.com/issue/RUBY-14678

  def m1(a, b)
    a * b
  end

  def one_more_example
    m1(1, 2)
    m1(1 + 1, 1 + 1)
  end
end
