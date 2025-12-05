module Admin
  # Admin controller for managing organizational locations/branches.
  # Handles CRUD operations for locations that can be assigned to users and and posts.
  class LocationsController < BaseController
    before_action :require_admin!
    before_action :set_location, only: %i[edit update destroy]

    def index
      @locations = Location.ordered.page(params[:page]).per(25)
    end

    def new
      @location = Location.new
    end

    def edit; end

    def create
      @location = Location.new(location_params)

      if @location.save
        redirect_to admin_locations_path, notice: t("admin.locations.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @location.update(location_params)
        redirect_to admin_locations_path, notice: t("admin.locations.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      if @location.destroyable?
        @location.destroy
        redirect_to admin_locations_path, notice: t("admin.locations.deleted")
      else
        redirect_to admin_locations_path, alert: t("admin.locations.cannot_delete")
      end
    end

    private

    def set_location
      @location = Location.find(params[:id])
    end

    def location_params
      params.expect(location: %i[code name active])
    end
  end
end
