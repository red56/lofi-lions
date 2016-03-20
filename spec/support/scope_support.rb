def allow_to_behave_like_scope(scope)
  like_a_scope(scope)
end

# allows an array to behave like a scope
def like_a_scope(array, type: nil)
  array.tap do |scope|
    scope.define_singleton_method(:includes){|*args| scope}
    scope.define_singleton_method(:where){|*args| scope}
    scope.define_singleton_method(:joins){|*args| scope}
    scope.define_singleton_method(:limit){|*args| scope}
    scope.define_singleton_method(:order){|*args| scope}
    scope.define_singleton_method(:reorder){|*args| scope}
    scope.define_singleton_method(:select){|*args| scope}
    scope.define_singleton_method(:per){|*args| scope} #kaminari
    scope.define_singleton_method(:page){|*args| scope} #kaminari
    case type
    when nil
    else
      fail "case for #{type} not found"
    end
  end
end
