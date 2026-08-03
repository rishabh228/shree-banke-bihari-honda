# frozen_string_literal: true

module Admin
  class ContactPagesController < BaseController
    before_action :set_setting

    def edit
      authorize @setting, :edit?, policy_class: ContactPagePolicy
    end

    def update
      authorize @setting, :update?, policy_class: ContactPagePolicy

      if @setting.update(contact_page_params)
        redirect_to edit_admin_contact_page_path, notice: "Contact page was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_setting
      @setting = Setting.instance
    end

    def contact_page_params
      params.require(:setting).permit(
        :showroom_name,
        :contact_page_heading,
        :contact_page_intro,
        :address,
        :phone,
        :email,
        :whatsapp,
        :business_hours,
        :google_map_link,
        :google_map_embed_url,
        :facebook,
        :instagram,
        :youtube,
        :footer_tagline
      )
    end
  end
end
