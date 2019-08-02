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
COPY mix.exs .
COPY mix.lock .
COPY run.sh .
RUN chmod +x run.sh
CMD ["./run.sh"]

# Fetch the application dependencies and build the application
RUN mix deps.get --only prod
RUN mix deps.compile
COPY assets ./assets
COPY priv ./priv
RUN cd assets && npm install && cd ..
RUN npm run deploy --prefix ./assets
COPY config ./config
COPY lib ./lib

RUN mix phx.digest
RUN mix release
