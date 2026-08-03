# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy]

    def index
      authorize User

      @q = policy_scope(User).ransack(params[:q])
      @pagy, @users = pagy(@q.result.order(:name))
    end

    def show
      authorize @user
    end

    def new
      @user = User.new
      authorize @user
    end

    def edit
      authorize @user
    end

    def create
      @user = User.new(user_params)
      authorize @user

      if @user.save
        redirect_to admin_user_path(@user), notice: "User was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @user

      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @user

      if @user == current_user
        redirect_to admin_users_path, alert: "You cannot delete your own account."
        return
      end

      @user.destroy!
      redirect_to admin_users_path, notice: "User was successfully deleted."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      permitted = %i[name email role]
      permitted += %i[password password_confirmation] if params.dig(:user, :password).present?
      params.require(:user).permit(permitted)
    end
  end
end
