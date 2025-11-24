# Notice Board

A Rails 8.1 application for managing and displaying news posts across multiple locations with RSS feed integration.

## Features

- **Multi-location News Management**: Create and manage news posts for different locations or organization-wide
- **Multiple Content Types**: Support for plain text, rich text (with ActionText), images, and PDF documents
- **RSS Feed Integration**: Automatic fetching and display of content from external RSS feeds
- **Role-based Access Control**: Four user roles (Superadmin, Admin, Location, General) with different permissions
- **Admin Panel**: Comprehensive administration interface for managing users, locations, news posts, and RSS feeds
- **Responsive Design**: Mobile-friendly interface built with Tailwind CSS
- **Background Jobs**: Sidekiq for RSS feed fetching and other async tasks
- **Internationalization**: Support for multiple languages (Polish/English)

## Tech Stack

- **Framework**: Ruby on Rails 8.1
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Background Jobs**: Sidekiq with Sidekiq-Cron
- **Authentication**: Devise
- **Authorization**: ActionPolicy
- **View Components**: ViewComponent
- **Asset Pipeline**: Propshaft
- **Testing**: RSpec, Capybara, FactoryBot
- **Code Quality**: Rubocop, Brakeman, Database Consistency

## Prerequisites

- Ruby 3.3+
- PostgreSQL 14+
- Node.js 18+
- Redis (for Sidekiq)

## Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd notice-board
```

### 2. Install dependencies

```bash
bundle install
npm install
```

### 3. Configure environment

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and configure your database credentials and other settings:

```
DATABASE_URL=postgresql://username:password@localhost/notice_board_development
REDIS_URL=redis://localhost:6379/0
```

### 4. Setup database

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

The seed file will create:
- A superadmin user (check `db/seeds.rb` for credentials)
- Sample locations
- Sample users with different roles

### 5. Start the development server

```bash
bin/dev
```

This will start:
- Rails server (port 3000)
- Sidekiq background worker
- CSS and JS build watchers

Visit http://localhost:3000 to access the application.

## User Roles

### Superadmin
- Full system access
- Can manage all users, locations, and content
- Cannot be created through the UI (only via seeds/console)

### Admin
- Can manage all locations and users (except superadmins)
- Can create news posts for any location
- Can manage RSS feeds

### Location
- Can only manage content for their assigned location
- Can create and edit news posts for their location
- Cannot manage users or other locations

### General
- Can create general (organization-wide) news posts
- No location-specific permissions
- Cannot manage users or other locations

## Development

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/news_post_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Code Quality

```bash
# Run Rubocop
bundle exec rubocop

# Auto-fix Rubocop violations
bundle exec rubocop -A

# Run Brakeman security scanner
bundle exec brakeman

# Check database consistency
bundle exec database_consistency
```

### Background Jobs

To manually run background jobs in development:

```bash
bundle exec sidekiq
```

RSS feeds are automatically fetched every hour via Sidekiq-Cron.

## Deployment

### Using Kamal

The application is configured for deployment with Kamal:

```bash
# Setup servers
kamal setup

# Deploy
kamal deploy

# Check status
kamal app logs
```

### Environment Variables

Required production environment variables:

- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `SECRET_KEY_BASE`: Rails secret key base
- `RAILS_LOG_TO_STDOUT`: Set to `true` for Docker/Kamal
- `RAILS_SERVE_STATIC_FILES`: Set to `true` for Docker/Kamal

## Configuration

### RSS Feed Settings

RSS feed fetch configuration can be adjusted in `app/services/rss_feeds/fetch_service.rb`:

- `OPEN_TIMEOUT`: Connection timeout (default: 10 seconds)
- `READ_TIMEOUT`: Read timeout (default: 15 seconds)
- `MAX_REDIRECTS`: Maximum redirects to follow (default: 3)
- `MAX_RESPONSE_SIZE`: Maximum feed size (default: 5MB)

### News Post Display Duration

Display duration limits in `app/models/news_post.rb`:

- `MIN_DISPLAY_DURATION`: Minimum duration (default: 1 second)
- `MAX_DISPLAY_DURATION`: Maximum duration (default: 300 seconds)

## API Endpoints

Currently, there are no public API endpoints. All functionality is accessible through the web interface.

## Security Features

- **CSRF Protection**: Enabled by default
- **Content Security Policy**: Configured for XSS protection
- **Rate Limiting**: Rack::Attack configured for DoS protection
- **SSRF Protection**: RSS feeds block private IPs
- **SQL Injection Prevention**: Parameterized queries throughout
- **Strong Migrations**: Catches unsafe database migrations

## Monitoring

- **PGHero**: Database performance monitoring at `/pghero` (admin only)
- **Prosopite**: N+1 query detection in development
- **Lograge**: Structured logging for production

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Noticeboard is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).