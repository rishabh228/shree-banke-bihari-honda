# frozen_string_literal: true

module Public
  class PagesController < BaseController
    RESERVED_SLUGS = %w[about contact privacy terms].freeze

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

    def show
      slug = params[:slug].to_s
      if RESERVED_SLUGS.include?(slug)
        redirect_to public_send("#{slug}_path"), status: :moved_permanently
        return
      end

      @page = Page.published_pages.friendly.find(slug)
    rescue ActiveRecord::RecordNotFound
      raise ActionController::RoutingError, "Not Found"
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
