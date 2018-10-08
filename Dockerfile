FROM ruby:2.5.1

ARG aws_access_key_id
ARG aws_secret_access_key
ARG aws_region

ENV AWS_ACCESS_KEY_ID "${aws_access_key_id}"
ENV AWS_SECRET_ACCESS_KEY "${aws_secret_access_key}"
ENV AWS_REGION "${aws_region}"

EXPOSE 3000

COPY --from=yuyat/guruguru-cache /usr/local/bin/guruguru-cache /usr/local/bin

WORKDIR /app
COPY Gemfile /app
COPY Gemfile.lock /app

RUN guruguru-cache restore --s3-bucket=yuyat-guruguru-cache-example \
  'gem-v1-{{ arch }}-{{ checksum "Gemfile.lock" }}' \
  'gem-v1-{{ arch }}'

RUN bundle install --path=vendor/bundle --clean

RUN guruguru-cache store --s3-bucket=yuyat-guruguru-cache-example \
  'gem-v1-{{ arch }}-{{ checksum "Gemfile.lock" }}' \
  vendor/bundle

COPY . /app

CMD ["./bin/rails", "s"]
