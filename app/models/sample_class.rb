class SampleClass

  attr_reader :api_client

  def initialize(mock: false, api_client: nil)
    if mock
      @api_client = ApiClientMock.new("flong", override: "bling")
    else
      @api_client = api_client
    end
  end

  def double_ctrl_space
    raise Extern
    # place cursor at end of previous line "raise Extern|".
    # ctrl-space for code completion basic
    # --> No responses.
    # ctrl-space again...
    # --> get expected code completion ("ExternalLibraries" etc)
    # Seems similar to the behaviour in https://youtrack.jetbrains.com/issue/RUBY-19385#comment=27-2836602
  end

end
