# frozen_string_literal: true

module Public
  class EnquiriesController < BaseController
    def new
      @enquiry = Enquiry.new(enquiry_prefill_params)
      @bikes = Bike.published_bikes.order(:name)
      authorize @enquiry
    end

    def create
      @enquiry = Enquiry.new
      authorize @enquiry

      result = Enquiries::CreateService.new(enquiry_params).call

      if result[:success]
        redirect_to enquiry_success_path(result[:enquiry]),
                    status: :see_other,
                    flash: {
                      notice: "Thank you! Your enquiry has been submitted successfully.",
                      whatsapp_customer_url: result[:whatsapp_customer_url]
                    }
      else
        @enquiry = result[:enquiry]
        prepare_failure_context
        flash.now[:alert] = result[:errors]&.to_sentence.presence ||
                            "Unable to submit your enquiry. Please check the form and try again."
        render enquiry_failure_template, status: :unprocessable_entity
      end
    end

    private

    def enquiry_params
      permitted = params.require(:enquiry).permit(:name, :phone, :email, :message, :bike_id, :source)
      permitted[:source] = resolved_source if permitted[:source].blank?
      permitted
    end

    def enquiry_prefill_params
      {
        source: resolved_source,
        bike_id: params[:bike_id]
      }.compact
    end

    def resolved_source
      source = params[:source].presence || params.dig(:enquiry, :source).presence
      return source if source.present? && Enquiry.sources.key?(source.to_s)

      contact_submission? ? "contact_form" : "general"
    end

    def contact_submission?
      request.path == contact_path || request.referer&.include?("/contact")
    end

    def enquiry_success_path(enquiry)
      case enquiry.source
      when "finance" then finance_path
      when "insurance" then insurance_path
      when "contact_form" then contact_path
      else root_path
      end
    end

    def prepare_failure_context
      @bikes = Bike.published_bikes.order(:name)
      @settings = current_settings
      @published_bikes = @bikes if finance_or_insurance_enquiry?
    end

    def finance_or_insurance_enquiry?
      @enquiry.source.in?(%w[finance insurance])
    end

    def enquiry_failure_template
      case @enquiry.source
      when "finance" then "public/finance/index"
      when "insurance" then "public/insurance/index"
      when "contact_form" then "public/pages/contact"
      else :new
      end
    end
  end
end
