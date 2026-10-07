FROM ruby:3.3-slim
WORKDIR /app
RUN apt-get update -qq && apt-get install -y build-essential libsqlite3-dev
RUN gem install sinatra net-ssh webrick sqlite3 rackup puma
COPY app.rb .
EXPOSE 4567
CMD ["ruby", "app.rb"]
