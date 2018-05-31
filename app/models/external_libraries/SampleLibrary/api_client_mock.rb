class ApiClientMock
  def initialize(secret, override: nil)
    @override = override
  end

  def start(arg)
    puts "override: #{@override.inspect}"
    puts "arg: #{arg.inspect}"
  end
end
