# frozen_string_literal: true

module Public
  class TestRidesController < BaseController
    def new
      @test_ride = TestRide.new(test_ride_prefill_params)
      @bikes = Bike.published_bikes.order(:name)
      authorize @test_ride
    end

    def create
      @test_ride = TestRide.new(test_ride_params)
      authorize @test_ride

      if @test_ride.save
        redirect_to root_path, notice: "Your test ride request has been submitted. We will contact you shortly."
      else
        @bikes = Bike.published_bikes.order(:name)
        flash.now[:alert] = "Unable to submit your test ride request. Please check the form and try again."
        render :new, status: :unprocessable_entity
      end
    end

    private

    def test_ride_params
      params.require(:test_ride).permit(:name, :phone, :email, :bike_id, :preferred_date, :preferred_time, :remarks)
    end

    def test_ride_prefill_params
      params.permit(:bike_id).slice(:bike_id)
    end
  end
end
