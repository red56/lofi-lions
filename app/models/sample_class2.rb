class SampleClass2

  attr_reader :api_client

  def initialize(mock: false, api_client: nil)
    if mock
      @api_client = ApiClientMock.new("flong", override: "bling")
    else
      @api_client = api_client
    end
  end

  def overconfident
    File.open(url) do |tempfile|
      file_type = correct_mimetype(entry.file_content_type)
      api_client.start(file_type)
      # Command-click "start" to navigate
      # I would expect a list including ApiClient#start and ApiClientMock#start
      # however it goes straight to ApiClient#start
    end
  end

  def api_client
    @api_client ||= ApiClient.new("flong")
  end

end
