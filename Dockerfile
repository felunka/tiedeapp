# Use ruby image to build our own image
FROM ruby:2.7

# Install node and yarn
RUN apt-get update -qq && apt-get install -y nodejs npm yarn postgresql-client

# Create work dir
RUN mkdir /app
WORKDIR /app

# Install yarn
RUN npm install -g yarn

# Install gems
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Copy rails code
ADD . /app
RUN bundle exec rake assets:precompile

EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
