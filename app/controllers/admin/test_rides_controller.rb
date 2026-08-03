# frozen_string_literal: true

module Admin
  class TestRidesController < BaseController
    before_action :set_test_ride, only: %i[show edit update destroy transition]

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
        redirect_to admin_test_ride_path(@test_ride), notice: "Test ride status updated successfully."
      else
        redirect_to admin_test_ride_path(@test_ride), alert: result[:error]
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
