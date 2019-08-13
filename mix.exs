defmodule AwesomeElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :awesome_elixir,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.html": :test]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AwesomeElixir.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.9"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1"},
      {:ecto_fields, github: "unitymind/ecto_fields", ref: "with_typespecs"},
      {:typed_ecto_schema, "~> 0.1.0"},
      {:typed_struct, "~> 0.1.4"},
      {:memoize, "~> 1.3"},
      {:postgrex, "~> 0.15.0"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:ex_check, "~> 0.9.0", only: :dev, runtime: false},
      {:exvcr, "~> 0.10.3", only: :test},
      {:ex_machina, "~> 2.3", only: :test},
      {:faker, "~> 0.12", only: :test},
      {:floki, "~> 0.21.0", only: :test},
      {:excoveralls, "~> 0.11.1", only: :test},
      {:gettext, "~> 0.17"},
      {:jason, "~> 1.1"},
      {:poison, "~> 4.0"},
      {:plug_cowboy, "~> 2.1"},
      {:httpoison, "~> 1.5"},
      {:earmark, "~> 1.3"},
      {:rihanna, github: "unitymind/rihanna", ref: "feature/delete-by-with-args"},
      {:timex, "~> 3.6"},
      {:basic_auth, "~> 2.2.2"},
      {:observer_cli, "~> 1.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp releases() do
    [
      awesome_elixir: [
        include_executables_for: [:unix]
      ]
    ]
  end
end
