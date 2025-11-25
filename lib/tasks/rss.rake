namespace :rss do
  desc "Fetch all active RSS feeds"
  task fetch: :environment do
    puts "Fetching RSS feeds..."

    feeds = RssFeed.active

    if feeds.empty?
      puts "No active RSS feeds found. Add some via the admin panel first."
      exit
    end

    feeds.each do |feed|
      print "Fetching #{feed.name}... "

      result = RssFeeds::FetchService.new(rss_feed: feed).call

      if result.success?
        puts "✓ (#{result.items_count} items)"
      else
        puts "✗ (#{result.errors.join(', ')})"
      end
    end

    puts "\nDone! Total RSS items: #{RssFeedItem.count}"
  end

  desc "Show RSS feed stats"
  task stats: :environment do
    puts "RSS Feed Statistics"
    puts "=" * 50
    puts "Active feeds: #{RssFeed.active.count}"
    puts "Inactive feeds: #{RssFeed.where(active: false).count}"
    puts "Total feed items: #{RssFeedItem.count}"
    puts ""

    RssFeed.active.each do |feed|
      puts "#{feed.name}: #{feed.rss_feed_items.count} items"
    end
  end

  desc "Clean up RSS feed URLs (strip whitespace)"
  task clean_urls: :environment do
    puts "Cleaning up RSS feed URLs..."

    RssFeed.find_each do |feed|
      original_url = feed.url
      feed.save # This will trigger the before_validation callback

      puts "✓ Cleaned: #{feed.name} (removed whitespace)" if original_url != feed.url
    end

    puts "Done!"
  end
end
