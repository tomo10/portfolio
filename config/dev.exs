import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :portfolio, PortfolioWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  # SETUP_TODO: regenerate and replace this secret_key_base with `mix phx.gen.secret`
  secret_key_base: "F8XDX1h1a7b8hccDSDG9WJgFPeAgDvRbMbpnsv2eFaEzW4cUXMX81Z4v/oTade48",
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :portfolio, PortfolioWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/portfolio_web/.*(ex|heex)$",
      ~r"lib/portfolio_web/(controllers|live|views|components|templates)/.*(ex|heex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Used in Util.email_valid?
# In dev mode we don't bother with MX record check - just the string format.
# In prod.ex MX checking is enabled
config :email_checker,
  default_dns: :system,
  also_dns: [],
  validations: [EmailChecker.Check.Format],
  smtp_retries: 2,
  timeout_milliseconds: :infinity

# Uncomment when you want to send test emails:
# Also ensure in config.exs that mailer_default_from_email is set to an email that is whitelisted on Amazon SES
# config :portfolio, Portfolio.Mailer,
#   adapter: Swoosh.Adapters.AmazonSES,
#   region: System.get_env("AWS_REGION"),
#   access_key: System.get_env("AWS_ACCESS_KEY"),
#   secret: System.get_env("AWS_SECRET")

config :portfolio, :env, :dev
