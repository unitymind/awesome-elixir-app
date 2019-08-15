# ---- Build Stage ----
FROM elixir:alpine as build

ENV MIX_ENV=prod \
    LANG=C.UTF-8

# Install required packages
RUN apk --no-cache add git nodejs nodejs-npm

# Create the application build directory
RUN mkdir /app
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

# Build assets
COPY assets assets
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# Build project
COPY priv priv
COPY lib lib
RUN mix compile
RUN mix docs

# Build release
COPY rel rel
RUN mix release

# ---- App Stage ----
FROM alpine:3.9 AS app
RUN apk add --no-cache bash openssl

RUN mkdir /app
WORKDIR /app
ENV HOME=/app

# Copy and prepare run script
COPY run.sh .
RUN chmod +x run.sh

COPY --from=build /app/_build/prod/rel/awesome_elixir ./
RUN chown -R nobody: /app
USER nobody

CMD ["./run.sh"]
