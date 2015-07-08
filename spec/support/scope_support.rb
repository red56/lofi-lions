# This allows us to let the passed in scope behave like a scope (accept .order and .includes and return itself)
def allow_to_behave_like_scope(scope)
  scope.define_singleton_method(:order) { |*args| scope }
  scope.define_singleton_method(:includes) { |*args| scope }
end
