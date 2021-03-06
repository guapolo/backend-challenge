# EverlyWell Backend Challenge

## Application stack

- PostgreSQL v12+
- Redis 5.0+
- Ruby 2.7.2
- Ruby on Rails 6.1

## Environmental variables

```bash
# Database URL. REQUIRED.
DATABASE_URL=
# JWT HMAC secret
JWT_HMAC_SECRET=
# Rails master key for decrypting credentials file
RAILS_MASTER_KEY=
# REDIS URL. REQUIRED.
REDIS_URL=
```

## Development environment

### Dependencies

- Bundler 2.1+
- Docker
- Graphviz
- [Homebrew](https://brew.sh)
- [RVM](https://rvm.io)

### Setup

```bash
# Afer installing RVM, create and use gemset
rvm use 2.7.2@expertsdir --create --install

# For rails-erd gem
brew install graphviz

# Setup a PostgreSQL instance with Docker
docker run --name pg12 -p 5432:5432 -e POSTGRES_PASSWORD=123456 -e POSTGRES_USER=gu -d postgres:12-alpine

# Spin up a Redis 5 Docker container
docker run --name redis -p 6379:6379 -d redis:5-alpine

# Gem installation (make sure it's v2.1+)
gem install bundler foreman
bundle

# If you need to add env variables use the base templates with necessary env vars
# cp .env.development .env.development.local
# cp .env.test .env.test.local

#Setup the databases
bin/rails db:create db:schema:load RAILS_ENV=test
bin/rails db:create db:schema:load

# generate the api docs
bin/rails docs:generate

# Open the docs
open docs/api/index.html

# Use forman to run the app
foreman start
# or
#
# Run the web server with:
# bundle exec puma -C config/puma.rb
#
# Run Sidekiq workers
# bundle exec sidekiq -C config/sidekiq.yml -t 25

# Check that the app is alive
open http://0.0.0.0:5000

# Seed the dev database, requires Sidekiq to be running to run some member creation tasks.
# A user (login: test_pilot, password: see credentials.yml.enc file) will be created.
bin/rails db:seed

# Once DB seeding is done, you can generate a JWT token so you can run some requests to the API with your preferred tool.
bin/rails runner 'puts Authorization.create_token(User.last)' > .jwt
# There's also an authentication endpoint, in case you want to do all the auth dance to get a JWT. Please refer to the
# docs or specs.
```

### Considerations when running migrations in development mode

Running `rails db:migrate` will update the `erd.png` diagram and annotate the models, factories and specs.

## Documentation

## Important Notes

- I used Bitly instead of Google Shortener (the services is deprecated since 2018). An API key is provided in the credentials file to be used while reviewing the app.
- The API conforms to the JSON API spec.
- Generating the docs will allow you to copy-paste cURL commands with a valid JWT. To generate the API documentation run `bin/rails docs:generate`. The documentation can be found in [docs/api/index.html](docs/api/index.html). To browse the documentation, type `open docs/api/index.html` after generating it.
- The requirements listed below have specs, the presentation ("views") are JSON documents since the project is a JSON API.

---

### Overview

Using Ruby on Rails, we'd like you to create a simple experts directory search tool. The tool can either be a full featured application or API only.

- Spend no more than 4 hours coding for the project. Do not include any initial application setup in this time limit.

### Requirements

The application should fulfill the following requirements:

- A member can be created using their name and a personal website address.
- When a member is created, all the heading (h1-h3) values are pulled in from the website to that members profile.
- The website url is shortened (e.g. using [http://goo.gl](http://goo.gl)).
- After the member has been added, I can define their friendships with other existing members. Friendships are bi-directional i.e. If David is a friend of Oliver, Oliver is always a friend of David as well.
- The interface should list all members with their name, short url and the number of friends.
- Viewing an actual member should display the name, website URL, shortening, website headings, and links to their friends' pages.
- Now, looking at Alan's profile, I want to find experts in the application who write about a certain topic and are not already friends of Alan.
- Results should show the path of introduction from Alan to the expert e.g. Alan wants to get introduced to someone who writes about 'Dog breeding'. Claudia's website has a heading tag "Dog breeding in Ukraine". Bart knows Alan and Claudia. An example search result would be Alan -> Bart -> Claudia ("Dog breeding in Ukraine").

We encourage the use of any libraries for everything except the search functionality, in which we want to see your simple algorithm approach.

### Add-ons:

- Sign up/log in functionality
- A UI that expands upon the basic requirements to have a user-friendly look and feel
- Anything else you, as a user, would enjoy seeing in an interface like this

### Things we're looking for:

- Navigable code
- Efficient algorithms
- Good separation of concerns
- Error handling
- Usage of gems/libraries

### Things we like:

- Well commented & well organized code
- Quality over quantity (the code you write should be good)
- Small, meaningful, commits
- Tests!
- Respect for the time limit - if you are in the midst of some work that you would like to finish, but have hit the 4 hour time limit, please split additional work into a separate branch, to be evaluated separately

### Submission

- __Fork__ this repository to your own git
- Remember to make meaningful commits as you work
- Somehow share your repository with us
- __Important:__ If there are credentials required (.env or master.key file), please email these to us directly or we can’t review your project
