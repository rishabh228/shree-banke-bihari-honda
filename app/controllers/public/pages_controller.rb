# frozen_string_literal: true

module Public
  class PagesController < BaseController
    before_action :load_page, only: %i[about contact privacy terms]

    def about
    end

    def contact
      @enquiry = Enquiry.new(source: :contact_form)
    end

    def privacy
    end

    def terms
    end

    private

    def load_page
      @page = Page.published_pages.friendly.find(page_slug)
    rescue ActiveRecord::RecordNotFound
      @page = nil
      flash.now[:alert] = "This page is not available right now."
    end

    def page_slug
      action_name
    end
  end
end
