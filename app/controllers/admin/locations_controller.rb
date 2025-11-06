# frozen_string_literal: true

module Admin
  class LocationsController < BaseController
    before_action :require_admin!
    before_action :set_location, only: [:edit, :update, :destroy]

    def index
      @locations = Location.ordered.all
    end

    def new
      @location = Location.new
    end

    def create
      @location = Location.new(location_params)

      if @location.save
        redirect_to admin_locations_path, notice: t('admin.locations.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @location.update(location_params)
        redirect_to admin_locations_path, notice: t('admin.locations.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @location.users.exists? || @location.news_posts.exists?
        redirect_to admin_locations_path, alert: t('admin.locations.cannot_delete')
      else
        @location.destroy
        redirect_to admin_locations_path, notice: t('admin.locations.deleted')
      end
    end

    private

    def set_location
      @location = Location.find(params[:id])
    end

    def location_params
      params.require(:location).permit(:code, :name, :active)
    end
  end
end