# frozen_string_literal: true

module Admin
  class RssFeedsController < BaseController
    before_action :require_admin!
    before_action :set_rss_feed, only: %i[edit update destroy refresh preview]

    def index
      @rss_feeds = RssFeed.ordered.page(params[:page]).per(25)
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
      result = RssFeeds::FetchService.new(rss_feed: @rss_feed).call

      if result.success?
        # Fetch the latest items for preview
        @preview_items = @rss_feed.rss_feed_items.order(published_at: :desc).limit(10)
        render :preview
      else
        flash[:alert] = t("admin.rss_feeds.preview_failed", errors: result.errors.join(", "))
        redirect_to admin_rss_feeds_path
      end
    rescue StandardError => e
      flash[:alert] = t("admin.rss_feeds.preview_failed", errors: e.message)
      redirect_to admin_rss_feeds_path
    end

    private

    def set_rss_feed
      @rss_feed = RssFeed.find(params[:id])
    end

    def rss_feed_params
      params.expect(rss_feed: %i[name url active])
    end
  end
end
