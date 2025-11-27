module Admin
  class RssFeedsController < BaseController
    before_action :require_admin!
    before_action :set_rss_feed, only: %i[edit update destroy refresh preview]

    def index
      @rss_feeds = RssFeed.includes(:rss_feed_items).ordered.page(params[:page])
    end

    def new
      @rss_feed = RssFeed.new
    end

    def edit; end

    def create
      @rss_feed = RssFeed.new(rss_feed_params)

      if @rss_feed.save
        redirect_to admin_rss_feeds_path, notice: t("admin.rss_feeds.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @rss_feed.update(rss_feed_params)
        redirect_to admin_rss_feeds_path, notice: t("admin.rss_feeds.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @rss_feed.destroy
      redirect_to admin_rss_feeds_path, notice: t("admin.rss_feeds.deleted")
    end

    def refresh
      result = RssFeeds::FetchService.new(rss_feed: @rss_feed).call

      if result.success?
        flash[:notice] = t("admin.rss_feeds.refreshed", count: result.items_count)
      else
        flash[:alert] = t("admin.rss_feeds.refresh_failed", errors: result.errors.join(", "))
      end

      redirect_to admin_rss_feeds_path
    end

    def preview
      result = fetch_and_validate_feed
      return handle_preview_failure(result) unless result.success?

      @preview_items = fetch_preview_items
      render :preview
    rescue StandardError => e
      handle_preview_error(e)
    end

    private

    def set_rss_feed
      @rss_feed = RssFeed.find(params[:id])
    end

    def rss_feed_params
      params.expect(rss_feed: %i[name url active])
    end

    def fetch_and_validate_feed
      RssFeeds::FetchService.new(rss_feed: @rss_feed).call
    end

    def fetch_preview_items
      @rss_feed.rss_feed_items.order(published_at: :desc).limit(10)
    end

    def handle_preview_failure(result)
      flash[:alert] = t("admin.rss_feeds.preview_failed", errors: result.errors.join(", "))
      redirect_to admin_rss_feeds_path
    end

    def handle_preview_error(error)
      flash[:alert] = t("admin.rss_feeds.preview_failed", errors: error.message)
      redirect_to admin_rss_feeds_path
    end
  end
end
