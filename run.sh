#!/bin/sh

set -e

export RUN_SERVER=false
./_build/prod/rel/awesome_elixir/bin/awesome_elixir eval "AwesomeElixir.ReleaseTasks.migrate()"
export RUN_SERVER=true
./_build/prod/rel/awesome_elixir/bin/awesome_elixir start
