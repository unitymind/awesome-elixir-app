#!/bin/sh

set -e

export RUN_SERVER=false
./bin/awesome_elixir eval "AwesomeElixir.ReleaseTasks.migrate()"

export RUN_SERVER=true
./bin/awesome_elixir start
