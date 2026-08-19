# frozen_string_literal: true

module Admin
  class BikesController < BaseController
    before_action :set_bike, only: %i[show edit update destroy publish hide]

    def index
      authorize Bike

      @q = policy_scope(Bike).ransack(ransack_query_for(Bike))
      @pagy, @bikes = pagy(@q.result.includes(:bike_variants).order(created_at: :desc))
    end

    def export_pdf
      authorize Bike, :index?

      records = export_pdf_scope(Bike, includes: [ :bike_variants ])
      send_pdf_report(Reports::Pdf::BikesListReport, records, "bikes-list")
    end

    def show
      authorize @bike
    end

    def new
      @bike = Bike.new
      authorize @bike
      build_nested_associations
    end

    def edit
      authorize @bike
      build_nested_associations
    end

    def create
      @bike = Bike.new(bike_params)
      authorize @bike

      if @bike.save
        redirect_to admin_bike_path(@bike), notice: "Bike was successfully created."
      else
        build_nested_associations
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @bike

      if @bike.update(bike_params)
        redirect_to admin_bike_path(@bike), notice: "Bike was successfully updated."
      else
        build_nested_associations
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @bike

      @bike.destroy!
      redirect_to admin_bikes_path, notice: "Bike was successfully deleted."
    end

    def publish
      authorize @bike, :publish?

      result = Bikes::PublishService.new(@bike).call

      if result.success?
        redirect_to admin_bike_path(@bike), notice: "Bike was successfully published."
      else
        redirect_to admin_bike_path(@bike), alert: result.errors.join(", ")
      end
    end

    def hide
      authorize @bike, :hide?

      @bike.hide!
      redirect_to admin_bike_path(@bike), notice: "Bike was successfully hidden."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_bike_path(@bike), alert: e.record.errors.full_messages.join(", ")
    end

    private

    def set_bike
      @bike = Bike.friendly.find(params[:id])
    end

    def build_nested_associations
      @bike.bike_variants.build if @bike.bike_variants.empty?
      @bike.bike_features.build if @bike.bike_features.empty?
      @bike.bike_specifications.build if @bike.bike_specifications.empty?
    end

    def bike_params
      params.require(:bike).permit(
        :name, :slug, :category, :engine, :mileage, :power, :torque, :fuel_tank, :weight,
        :description, :status, :seo_title, :seo_description, :meta_keywords,
        :hsn_code, :gst_rate,
        :thumbnail, :brochure, images: [],
        bike_variants_attributes: %i[
          id name color ex_showroom_price insurance rto handling_charge
          accessories_charge total_price stock_quantity available _destroy
        ],
        bike_features_attributes: %i[id title position _destroy],
        bike_specifications_attributes: %i[id label value position _destroy]
      )
    end
  end
end
