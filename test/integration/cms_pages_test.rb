# frozen_string_literal: true

require "test_helper"

class CmsPagesRoutingTest < ActionDispatch::IntegrationTest
  setup do
    Setting.instance
    @page = Page.create!(title: "Warranty Policy", slug: "warranty", published: true)
    @page.update!(body: "<p>Warranty terms</p>")
  end

  test "published custom CMS pages are public" do
    host! "localhost"
    get cms_page_path("warranty"), headers: {
      "HTTP_USER_AGENT" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
    }
    assert_response :success
    assert_match "Warranty Policy", response.body
  end
end
