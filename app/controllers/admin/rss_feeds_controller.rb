# frozen_string_literal: true

module Admin
  class RssFeedsController < BaseController
    before_action :require_admin!
    before_action :set_rss_feed, only: [:edit, :update, :destroy]

    def index
      @rss_feeds = RssFeed.ordered.all
    end

    def new
      @rss_feed = RssFeed.new
    end

    def create
      @rss_feed = RssFeed.new(rss_feed_params)

      if @rss_feed.save
        redirect_to admin_rss_feeds_path, notice: t('admin.rss_feeds.created')
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @rss_feed.update(rss_feed_params)
        redirect_to admin_rss_feeds_path, notice: t('admin.rss_feeds.updated')
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @rss_feed.destroy
      redirect_to admin_rss_feeds_path, notice: t('admin.rss_feeds.deleted')
    end

    private

    def set_rss_feed
      @rss_feed = RssFeed.find(params[:id])
    end

    def rss_feed_params
      params.require(:rss_feed).permit(:name, :url, :active)
    end
  end
end