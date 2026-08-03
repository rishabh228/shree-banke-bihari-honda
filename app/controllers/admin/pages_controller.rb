# frozen_string_literal: true

module Admin
  class PagesController < BaseController
    before_action :set_page, only: %i[show edit update destroy]

    def index
      authorize Page

      @q = policy_scope(Page).ransack(params[:q])
      @pagy, @pages = pagy(@q.result.order(created_at: :desc))
    end

    def show
      authorize @page
    end

    def new
      @page = Page.new
      authorize @page
    end

    def edit
      authorize @page
    end

    def create
      @page = Page.new(page_params)
      authorize @page

      if @page.save
        redirect_to admin_page_path(@page), notice: "Page was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @page

      if @page.update(page_params)
        redirect_to admin_page_path(@page), notice: "Page was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @page

      @page.destroy!
      redirect_to admin_pages_path, notice: "Page was successfully deleted."
    end

    private

    def set_page
      @page = Page.friendly.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:title, :slug, :published, :body)
    end
  end
end
