module Capybara
  class Session
    def has_link_to?(path) # rubocop:disable Naming/PredicateName
      has_css?("a[href='#{path}']")
    end
  end
end
