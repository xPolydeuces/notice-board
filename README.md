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

### For Local Development (without Docker)
- Ruby 3.3+
- PostgreSQL 14+
- Node.js 18+
- Redis (for Sidekiq)

### For Docker Development
- Docker
- Docker Compose

## Docker Setup (Recommended)

The easiest way to get started is using Docker Compose, which sets up all required services automatically.

### 1. Clone the repository

```bash
git clone <repository-url>
cd notice-board
```

### 2. Configure environment

Copy the example environment file:

```bash
cp .env.example .env
```

For Docker development, update the `.env` file with these Docker-specific settings:

```env
DATABASE_URL=postgres://postgres:postgres@postgresql:5432/noticeboard_development
CACHE_DATABASE_URL=postgres://postgres:postgres@postgresql:5432/noticeboard_development_cache
REDIS_URL=redis://dragonfly:6379
```

### 3. Build and start the containers

```bash
docker-compose up --build
```

This will:
- Build the application container
- Start PostgreSQL database
- Start Dragonfly (Redis-compatible) for caching and background jobs
- Install all dependencies
- Start the Rails server on port 3000

### 4. Setup the database

In a new terminal, run:

```bash
docker-compose exec noticeboard bin/rails db:create db:migrate db:seed
```

The seed file will create:
- A superadmin user (check `db/seeds.rb` for credentials)
- Sample locations
- Sample users with different roles

### 5. Access the application

Visit http://localhost:3000 to access the application.

To access the admin panel at http://localhost:3000/admin, log in with the credentials from `db/seeds.rb`.

### Docker Commands Reference

```bash
# Start services
docker-compose up

# Start in background (detached mode)
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f noticeboard

# Run Rails console
docker-compose exec noticeboard bin/rails console

# Run tests
docker-compose exec noticeboard bundle exec rspec

# Run database migrations
docker-compose exec noticeboard bin/rails db:migrate

# Access bash shell in container
docker-compose exec noticeboard bash

# Rebuild containers after dependency changes
docker-compose up --build

# Clean up everything (including volumes)
docker-compose down -v
```

## Manual Setup

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

### Using Docker (Production)

The application includes a production-ready Dockerfile for deployment.

#### Building the Production Image

```bash
# Build the production image
docker build -t noticeboard:latest .

# Or with a specific tag
docker build -t noticeboard:v1.0.0 .
```

#### Running in Production

```bash
# Run the container with environment variables
docker run -d \
  -p 80:80 \
  -e DATABASE_URL=postgresql://user:password@dbhost:5432/noticeboard_production \
  -e REDIS_URL=redis://redis-host:6379/0 \
  -e SECRET_KEY_BASE=your-secret-key-base \
  -e RAILS_LOG_TO_STDOUT=true \
  -e RAILS_SERVE_STATIC_FILES=true \
  --name noticeboard \
  noticeboard:latest
```

#### Docker Compose for Production

Create a `docker-compose.prod.yml` file:

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/noticeboard_production
      REDIS_URL: redis://redis:6379/0
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      RAILS_ENV: production
      RAILS_LOG_TO_STDOUT: "true"
      RAILS_SERVE_STATIC_FILES: "true"
    depends_on:
      - db
      - redis
    restart: unless-stopped

  db:
    image: postgres:17
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: noticeboard_production
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

  sidekiq:
    build:
      context: .
      dockerfile: Dockerfile
    command: bundle exec sidekiq
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/noticeboard_production
      REDIS_URL: redis://redis:6379/0
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      RAILS_ENV: production
    depends_on:
      - db
      - redis
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

Deploy with:

```bash
# Generate secret key
export SECRET_KEY_BASE=$(docker run --rm noticeboard:latest bin/rails secret)

# Start services
docker-compose -f docker-compose.prod.yml up -d

# Setup database
docker-compose -f docker-compose.prod.yml exec app bin/rails db:create db:migrate db:seed
```

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
- `SECRET_KEY_BASE`: Rails secret key base (generate with `bin/rails secret`)
- `RAILS_LOG_TO_STDOUT`: Set to `true` for Docker/Kamal
- `RAILS_SERVE_STATIC_FILES`: Set to `true` for Docker/Kamal

Optional environment variables:

- `APP_NAME`: Application name (default: "Tablica Ogłoszeń")
- `APP_SUBTITLE`: Application subtitle (default: "Panel Administracyjny")
- `COMPANY_NAME`: Your company name
- `LOGO_URL`: URL to your company logo
- `ADMIN_EMAIL`: Admin contact email

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