FROM ruby:2.5.1

RUN apt-get update && apt-get install -y build-essential
RUN apt-get -y install mysql-client

RUN mkdir /myapp
WORKDIR /myapp
ENV BUNDLE_PATH /gems
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler && bundle install
COPY . /myapp

EXPOSE 3000
