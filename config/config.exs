# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# SETUP_TODO - ensure these details are correct
# Option descriptions:
#   - app_name: This appears in your email layout and also your meta title tag
#   - business_name: This appears in your landing page footer next to the copyright symbol
#   - support_email: In your transactional emails there is a "Contact us" email - this is what will appear there
#   - mailer_default_from_name: The "from" name for your transactional emails
#   - mailer_default_from_email: The "from" email for your transactional emails
#   - logo_url_for_emails: The URL to your logo for your transactional emails (needs to be a full URL, not a path)
#   - seo_description: Will go in your meta description tag
#   - twitter_url: (deletable) The URL to your Twitter account (used in the landing page footer)
#   - github_url: (deletable) The URL to your Github account (used in the landing page footer)
#   - discord_url: (deletable) The URL to your Discord invititation (used in the landing page footer)
config :portfolio,
  app_name: "THCE Portfolio",
  business_name: "Thomas Edwards Dev",
  support_email: "thce28@gmail.com",
  mailer_default_from_name: "Contact",
  mailer_default_from_email: "thce28@gmail.com",
  logo_url_for_emails: "",
  seo_description:
    "Portfolio website and contact information for Thomas Edwards full stack developer",
  github_url: "https://github.com/tomo10"

# Petal Pro features:
#   - impersonation_enabled?: Allows admins to impersonate users
# config :portfolio,
#   impersonation_enabled?: true

# config :portfolio,
#   ecto_repos: [Portfolio.Repo]

# Configures the endpoint
config :portfolio, PortfolioWeb.Endpoint,
  url: [host: "https://tedwards.dev"],
  render_errors: [
    formats: [html: PortfolioWeb.ErrorHTML, json: PortfolioWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Portfolio.PubSub,
  live_view: [signing_salt: "Fd8SWPu3"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :portfolio, Portfolio.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :petal_components,
       :error_translator_function,
       {PortfolioWeb.CoreComponents, :translate_error}

config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

# To configure our openai api keys
config :langchain, openai_key: "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"
config :langchain, openai_org_id: "org-Lx8ZdHwtk0dRTUwRKqwzC3IE"
# config :langchain, openai_key: System.get_env("OPENAI_KEY")
# config :langchain, openai_org_id: System.get_env("OPENAI_ORG_ID")

# Specify which languages you support
# To create .po files for a language run `mix gettext.merge priv/gettext --locale fr`
# (fr is France, change to whatever language you want - make sure it's included in the locales config below)
config :portfolio, PortfolioWeb.Gettext, allowed_locales: ~w(en fr)

config :portfolio, :language_options, [
  %{locale: "en", flag: "🇬🇧", label: "English"},
  %{locale: "fr", flag: "🇫🇷", label: "French"}
]

# Social login providers
# Full list of strategies: https://github.com/ueberauth/ueberauth/wiki/List-of-Strategies
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]},
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]}
  ]

# SETUP_TODO - If you want to use Github auth, replace MyGithubUsername with your Github username
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  headers: [
    "user-agent": "MyGithubUsername"
  ]

config :portfolio, :passwordless_enabled, true

# Reduce XSS risks by declaring which dynamic resources are allowed to load
# If you use any CDNs, whitelist them here.
# Policy struct: https://github.com/mbramson/content_security_policy/blob/master/lib/content_security_policy/policy.ex
# Read more about the options: https://content-security-policy.com
# Note that we use unsafe-eval because Alpine JS requires it :( (see https://alpinejs.dev/advanced/csp)
config :portfolio, :content_security_policy, %{
  default_src: [
    "'unsafe-inline'",
    "'unsafe-eval'",
    "'self'",
    "data:",
    "blob:",
    "https://cdnjs.cloudflare.com",
    "https://cdn.skypack.dev",
    "https://cdn.jsdelivr.net",
    "https://rsms.me",
    "https://res.cloudinary.com",
    "https://api.cloudinary.com",
    "https://lh3.googleusercontent.com",
    "*.amazonaws.com",
    "ws://localhost:4000"
  ]
}

# config :flop, repo: Portfolio.Repo, default_limit: 20
config :tesla, :adapter, {Tesla.Adapter.Finch, name: Portfolio.Finch}
config :petal_framework, :translation_helper_module, PortfolioWeb.PetalFrameworkTranslations

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
