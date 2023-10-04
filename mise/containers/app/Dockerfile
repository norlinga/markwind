# syntax=docker/dockerfile:1

FROM ruby:3.2.2-alpine AS base

RUN apk add --update --no-cache \
  file \
  gcompat \
  tzdata

FROM base AS builder

RUN apk add --update --no-cache \
  build-base \
  git \
  nodejs \
  npm \
  vips-dev \
  yarn 

FROM builder AS development

WORKDIR /app

COPY  Gemfile* ./


RUN bundle install -j4 --retry 3


RUN npm install -D @tailwindcss/typography

COPY . .

