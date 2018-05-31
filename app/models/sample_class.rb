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

  def for_strange_error
    raise ExternalLibraries::Errors::ApiError.new("library_ident", "method", "path", "data", "response_code", "body")
    # above line is marked as error in RubyMine "Found extra argument(s). Required <= 1: msg=… less... (⌘F1) "
    # ctrl-clicking `new` takes you to Exception.new
    # code introspection seems to be based on Exception.new, not to ExternalLibraries::Errors::ApiError#initialize
  end

  def non_navigable
    @api_client ||= ApiClient.new("flong")
    File.open(url) do |tempfile|
      file_type = correct_mimetype(entry.file_content_type)
      api_client.start(file_type)
      # command click on "start" for code navigation
      # I get no navigation suggestions
    end
  end

end
