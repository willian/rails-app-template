FROM ruby:2.4.1-slim

RUN apt-get update -qq \
  && apt-get upgrade -y \
  && apt-get install -y build-essential curl libpq-dev postgresql-client git \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get install -y nodejs \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
    | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update \
  && apt-get install -y yarn \
  && apt-get autoremove \
  && apt-get clean \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem update --system
RUN gem install bundler
RUN gem update && gem cleanup

RUN mkdir /app
WORKDIR /app

ENV BUNDLE_PATH /cache/{APP_NAME}/bundle

ADD . /app

RUN bundle check || bundle install
