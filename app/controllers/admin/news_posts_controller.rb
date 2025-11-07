# frozen_string_literal: true

module Admin
  class NewsPostsController < BaseController
    before_action :set_news_post, only: [:show, :edit, :update, :destroy, :publish, :unpublish, :archive, :restore]
    before_action :authorize_news_post, only: [:edit, :update, :destroy, :publish, :unpublish, :archive, :restore]

    def index
      @news_posts = NewsPost.with_associations.recent

      # Filter by location if current user is location-based
      if current_user.location? && current_user.location
        @news_posts = @news_posts.where(location_id: current_user.location_id)
      end

      # Apply filters from params
      @news_posts = @news_posts.where(location_id: params[:location_id]) if params[:location_id].present?
      @news_posts = @news_posts.where(published: params[:published]) if params[:published].present?
      @news_posts = @news_posts.where(archived: params[:archived]) if params[:archived].present?

      @locations = Location.active.ordered if current_user.admin?
    end

    def show
    end

    def new
      @news_post = NewsPost.new
      @locations = available_locations
    end

    def create
      @news_post = NewsPost.new(news_post_params)
      @news_post.user = current_user

      if @news_post.save
        redirect_to admin_news_posts_path, notice: t('admin.news_posts.created')
      else
        @locations = available_locations
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @locations = available_locations
    end

    def update
      if @news_post.update(news_post_params)
        redirect_to admin_news_posts_path, notice: t('admin.news_posts.updated')
      else
        @locations = available_locations
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @news_post.destroy
      redirect_to admin_news_posts_path, notice: t('admin.news_posts.deleted')
    end

    def publish
      if @news_post.publish!
        redirect_to admin_news_posts_path, notice: t('admin.news_posts.published')
      else
        redirect_to admin_news_posts_path, alert: t('admin.news_posts.publish_failed')
      end
    end

    def unpublish
      if @news_post.unpublish!
        redirect_to admin_news_posts_path, notice: t('admin.news_posts.unpublished')
      else
        redirect_to admin_news_posts_path, alert: t('admin.news_posts.unpublish_failed')
      end
    end

    def archive
      if @news_post.archive!
        redirect_to admin_news_posts_path, notice: t('admin.news_posts.archived')
      else
        redirect_to admin_news_posts_path, alert: t('admin.news_posts.archive_failed')
      end
    end

    def restore
      if @news_post.restore!
        redirect_to admin_news_posts_path, notice: t('admin.news_posts.restored')
      else
        redirect_to admin_news_posts_path, alert: t('admin.news_posts.restore_failed')
      end
    end

    private

    def set_news_post
      @news_post = NewsPost.find(params[:id])
    end

    def authorize_news_post
      # Admins can edit everything
      return if current_user.admin?

      # Location users can only edit their location's posts
      if current_user.location?
        unless @news_post.location_id == current_user.location_id
          redirect_to admin_news_posts_path, alert: t('admin.unauthorized', default: 'Brak uprawnień')
        end
        return
      end

      # General users can only edit general posts (no location)
      unless @news_post.general?
        redirect_to admin_news_posts_path, alert: t('admin.unauthorized', default: 'Brak uprawnień')
      end
    end

    def news_post_params
      permitted = [:title, :content, :post_type, :rich_content, :image]

      # Only admins can set location
      if current_user.admin?
        permitted << :location_id
      elsif current_user.location?
        # Location users can only create posts for their location
        params[:news_post][:location_id] = current_user.location_id
      else
        # General users can only create general posts (no location)
        params[:news_post][:location_id] = nil
      end

      params.require(:news_post).permit(*permitted)
    end

    def available_locations
      if current_user.admin?
        Location.active.ordered
      elsif current_user.location?
        Location.where(id: current_user.location_id)
      else
        Location.none
      end
    end
  end
end