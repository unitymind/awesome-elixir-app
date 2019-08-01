# ---- Build Stage ----
FROM elixir:alpine

ENV MIX_ENV=prod \
    LANG=C.UTF-8

# Install required packages
RUN apk --no-cache add openssl nodejs nodejs-npm git

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create the application build directory
RUN mkdir /app
WORKDIR /app

# Copy over all the necessary application files and directories
COPY assets ./assets
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

# Fetch the application dependencies and build the application
RUN mix deps.get --only prod
RUN mix deps.compile
RUN cd assets && npm install && cd ..
RUN npm run deploy --prefix ./assets
RUN mix phx.digest
RUN mix release

COPY run.sh .
RUN chmod +x run.sh

CMD ["./run.sh"]
