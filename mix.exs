defmodule Portfolio.MixProject do
  use Mix.Project

  @version "1.6.0"

  def project do
    [
      app: :portfolio,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        quality: :test,
        wallaby: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Portfolio.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  # Type `mix deps.update --all` to update deps (won't updated this file)
  # Type `mix hex.outdated` to see deps that can be updated
  defp deps do
    [
      # Phoenix base
      {:phoenix, "~> 1.7.3"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.1"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      # https://github.com/deadtrickster/ssl_verify_fun.erl/pull/27
      {:ssl_verify_fun, ">= 0.0.0", manager: :rebar3, override: true},

      # Hashing
      {:hashids, "~> 2.0"},

      # Assets
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},

      # Petal components and framework
      {:petal_components, "~> 1.7.1"},
      {:petal_framework, "~> 0.5", repo: "petal"},

      # Utils
      {:blankable, "~> 1.0.0"},
      {:timex, "~> 3.7", override: true},
      {:inflex, "~> 2.1.0"},
      {:slugify, "~> 1.3"},
      {:sizeable, "~> 1.0"},

      # Authentication
      {:ueberauth, "~> 0.10"},
      {:ueberauth_github, "~> 0.7"},

      # HTTP client
      {:tesla, "~> 1.7.0"},
      {:finch, "~> 0.14"},

      # HTTP libs for ad_astra
      {:httpoison, "~> 2.1"},
      {:poison, "~> 5.0"},

      # Libs for Ad Astra number formatting
      {:number, "~> 1.0.1"},

      # For llm chaning
      {:ecto, "~> 3.10.3"},
      {:langchain, "~> 0.1.0"},
      {:req, "~> 0.4.0"},

      # For markdown to html rendering
      {:earmark, "~> 1.4"},

      # Testing
      {:wallaby, "~> 0.30", runtime: false, only: :test},
      {:faker, "~> 0.17", only: [:test, :dev]},

      # Security
      {:content_security_policy, "~> 1.0"},

      # Code quality
      {:recode, "~> 0.4", only: [:dev, :test]},
      {:sobelow, "~> 0.12", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: [:dev, :test], runtime: false},

      # Temporary (to rename your project)
      {:rename_project, "~> 0.1.0", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      # Run to check the quality of your code
      quality: [
        "format --check-formatted",
        "sobelow --config",
        "coveralls",
        "credo",
        "recode"
      ],
      update_translations: ["gettext.extract --merge"],

      # Unlocks unused dependencies (no longer mentioned in the mix.exs file)
      clean_mix_lock: ["deps.unlock --unused"],

      # Only run wallaby (e2e) tests
      wallaby: ["test --only feature"],
      seed: ["run priv/repo/seeds.exs"]
    ]
  end
end
