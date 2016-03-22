RSpec::Matchers.define :have_link_to do |expected_path|

  def selector(expected_path)
    "a[href='#{expected_path}']"
  end

  match do |doc_or_page|
    case doc_or_page
    when Nokogiri::HTML::Document
      doc_or_page.css(selector(expected_path)).present?
    when Capybara::Session
      doc_or_page.current_scope.has_css?(selector(expected_path))
    else
      fail "Not expecting type: #{doc_or_page.class.name}"
    end
  end
  failure_message do |doc_or_page|
    case doc_or_page
    when Nokogiri::HTML::Document
      "expected that #{doc_or_page.to_s} would have a link to #{expected_path}"
    when Capybara::Session
      "expected a link to #{expected_path}"
    end

  end

end
