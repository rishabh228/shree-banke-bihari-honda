# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
    before_action :set_setting

    def show
      authorize @setting
    end

    def edit
      authorize @setting
    end

    def update
      authorize @setting

      if @setting.update(setting_params)
        redirect_to admin_settings_path, notice: "Settings were successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_setting
      @setting = Setting.instance
    end

    def setting_params
      params.require(:setting).permit(
        :showroom_name, :address, :phone, :email, :whatsapp, :whatsapp_notifications_enabled,
        :google_map_link, :google_map_embed_url,
        :contact_page_heading, :contact_page_intro, :footer_tagline,
        :facebook, :instagram, :youtube, :business_hours, :logo,
        :gstin, :pan, :state, :state_code, :invoice_prefix,
        :vehicle_gst_rate, :accessories_gst_rate, :vehicle_hsn, :accessories_hsn,
        :handling_hsn, :handling_gst_rate, :legal_name, :dealer_code,
        :bank_name, :bank_account_number, :bank_ifsc, :upi_id, :billing_terms,
        :labour_sac, :labour_gst_rate
      )
    end
  end
end
