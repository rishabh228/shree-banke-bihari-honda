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
        :showroom_name, :address, :phone, :email, :whatsapp, :google_map_link,
        :facebook, :instagram, :youtube, :business_hours, :logo
      )
    end
  end
end
