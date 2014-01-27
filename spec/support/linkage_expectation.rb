module Capybara
  class Session
    def has_link_to? path
      has_css?("a[href='#{path}']")
    end
  end
end