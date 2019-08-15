# AwesomeElixir

[![CircleCI](https://circleci.com/gh/unitymind/awesome-elixir-app.svg?style=svg)](https://circleci.com/gh/unitymind/awesome-elixir-app)

[![Screenshot-2019-08-15-at-18-31-46.png](https://i.postimg.cc/W4JHJnJ2/Screenshot-2019-08-15-at-18-31-46.png)](https://postimg.cc/SXkrBcr5)

## TDLR

Visit the running application at: [https://awesome-elixir.herokuapp.com](https://awesome-elixir.herokuapp.com)

Check generated **ExDoc** at: [https://awesome-elixir.herokuapp.com/docs/index.html](https://awesome-elixir.herokuapp.com/docs/index.html)

## Development

Issue new GitHub Personal Access Token without any allowed scope at: [https://github.com/settings/tokens](https://github.com/settings/tokens)

[![Screenshot-2019-08-15-at-18-47-58.png](https://i.postimg.cc/R0BvhNNb/Screenshot-2019-08-15-at-18-47-58.png)](https://postimg.cc/MndCrZ0y)

Application need them for expand rate limits on GitHub API calls.

### Local development server (`mix phx.server` way)

To start your application Phoenix server:

  * Install dependencies with `mix deps.get`
  * PostgreSQL config use default `postgres/postgres` username/password credentials.
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Copy config/dev.secret.example.exs `cp config/dev.secret.example.exs config/dev.secret.exs`
  * Replace `token` with issued GitHub Personal Access Token 
  * Start Phoenix endpoint with `mix phx.server`
  * You can play in IEx shell as usual: `iex -s mix` (no Phoenix Endpoint and Rihanna Job Dispatcher will be started)

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Refresh you page periodically to catch progress on initial data scraping from [https://github.com/h4cc/awesome-elixir](https://github.com/h4cc/awesome-elixir). 

### Local production server (`docker compose` way)

To start your application Phoenix server packed in docker using multi-stage build and `mix release` feature:

  * Run `GITHUB_TOKEN="your_issued_token" SECRET_KEY_BASE=$(mix phx.gen.secret) docker-compose up -d --build`
  
After build finished and docker-compose services up you can visit [`localhost:4001`](http://localhost:4001) from your browser.
  
To view logs from running system:
  
  * Run `docker-compose logs -f`
  
To reset your data:
  
  * Run `docker-compose down`
  * Run `docker volume rm awesome_elixir_postgres_data`
  * Repeat command from "To start section"

Please note that Ecto migration will be run as the part of startup process. No additional actions required.

Running IEx shell on running system:

  * Run `docker-compose exec web bash`
  * Run inside container shell: `bin/awesome_elixir remote`
  * Inside IEx shell: `:observer_cli.start()`

