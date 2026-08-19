# frozen_string_literal: true

module Admin
  class TestRidesController < BaseController
    before_action :set_test_ride, only: %i[show edit update destroy transition convert_to_enquiry convert_to_sale]

    def index
      authorize TestRide

      @q = policy_scope(TestRide).ransack(ransack_query_for(TestRide))
      @pagy, @test_rides = pagy(@q.result.includes(:bike).order(created_at: :desc))
    end

    def show
      authorize @test_ride
    end

    def edit
      authorize @test_ride
    end

    def update
      authorize @test_ride

      if @test_ride.update(test_ride_params)
        redirect_to admin_test_ride_path(@test_ride), notice: "Test ride was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @test_ride

      @test_ride.destroy!
      redirect_to admin_test_rides_path, notice: "Test ride was successfully deleted."
    end

    def transition
      authorize @test_ride, :update?

      result = TestRides::StatusTransitionService.new(@test_ride, params[:status]).call

      if result[:success]
        redirect_to admin_test_ride_path(@test_ride), notice: "Test ride status updated successfully.", status: :see_other
      else
        redirect_to admin_test_ride_path(@test_ride), alert: result[:error], status: :see_other
      end
    end

    def convert_to_enquiry
      authorize @test_ride, :convert_to_enquiry?

      result = TestRides::CreateEnquiryService.new(@test_ride).call
      if result[:success]
        redirect_to admin_enquiry_path(result[:enquiry]), notice: "Enquiry created from this test ride."
      else
        redirect_to admin_test_ride_path(@test_ride), alert: result[:errors].join(", ")
      end
    end

    def convert_to_sale
      authorize @test_ride, :convert_to_sale?

      result = TestRides::CreateSaleService.new(@test_ride, sales_executive: current_user).call
      if result[:success]
        redirect_to admin_sale_path(result[:sale]), notice: "Quotation created from this test ride."
      else
        redirect_to admin_test_ride_path(@test_ride), alert: Array(result[:errors]).join(", ")
      end
    end

    private

    def set_test_ride
      @test_ride = TestRide.find(params[:id])
    end

    def test_ride_params
      params.require(:test_ride).permit(
        :name, :phone, :email, :bike_id, :preferred_date, :preferred_time, :remarks, :status
      )
    end
  end
end
