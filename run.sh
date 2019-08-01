#!/bin/sh

set -e

mv config/prod.exs config/prod.exs.bak
cp config/deploy.exs config/prod.exs

mix ecto.migrate

mv config/prod.exs.bak config/prod.exs

./_build/prod/rel/awesome_elixir/bin/awesome_elixir start
