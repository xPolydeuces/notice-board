# frozen_string_literal: true

module Admin
  class NewsPostsController < BaseController
    before_action :set_news_post, only: [:show, :edit, :update, :destroy, :publish, :unpublish, :archive, :restore]

    def index
      # Use policy scope to filter posts based on user permissions
      @news_posts = authorized_scope(NewsPost.with_associations.recent)

      # Apply filters from params (admins can filter by any location)
      @news_posts = @news_posts.where(location_id: params[:location_id]) if params[:location_id].present?
      @news_posts = @news_posts.where(published: params[:published]) if params[:published].present?
      @news_posts = @news_posts.where(archived: params[:archived]) if params[:archived].present?

      @locations = Location.active.ordered if current_user.admin?
    end

    def show
      authorize! @news_post
    end

    def new
      @news_post = NewsPost.new
      authorize! @news_post, to: :create?
      @locations = available_locations
    end

    def create
      @news_post = NewsPost.new(news_post_params)
      @news_post.user = current_user
      authorize! @news_post

      if @news_post.save
        redirect_to admin_news_posts_path, notice: t('admin.news_posts.created')
      else
        @locations = available_locations
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! @news_post
      @locations = available_locations
    end

    def update
      authorize! @news_post
      if @news_post.update(news_post_params)
        redirect_to admin_news_posts_path, notice: t('admin.news_posts.updated')
      else
        @locations = available_locations
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! @news_post
      @news_post.destroy
      redirect_to admin_news_posts_path, notice: t('admin.news_posts.deleted')
    end

    def publish
      authorize! @news_post
      if @news_post.publish!
        redirect_to admin_news_posts_path, notice: t('admin.news_posts.published')
      else
        redirect_to admin_news_posts_path, alert: t('admin.news_posts.publish_failed')
      end
    end

    def unpublish
      authorize! @news_post
      if @news_post.unpublish!
        redirect_to admin_news_posts_path, notice: t('admin.news_posts.unpublished')
      else
        redirect_to admin_news_posts_path, alert: t('admin.news_posts.unpublish_failed')
      end
    end

    def archive
      authorize! @news_post
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

      # Use policy to check if user can assign location
      if allowed_to?(:assign_location?, NewsPost)
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