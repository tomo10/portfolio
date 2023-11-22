import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_OAUTH_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_OAUTH_SECRET")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_OAUTH_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_OAUTH_SECRET")

# If you are using Cloudinary for file uploads:
config :portfolio, :cloudinary,
  cloud_name: System.get_env("CLOUDINARY_CLOUD_NAME"),
  api_key: System.get_env("CLOUDINARY_API_KEY"),
  api_secret: System.get_env("CLOUDINARY_API_SECRET"),
  folder: System.get_env("CLOUDINARY_FOLDER")

# If you are using Amazon S3 for file uploads:
config :portfolio, :s3,
  region: System.get_env("AWS_REGION"),
  access_key: System.get_env("AWS_ACCESS_KEY"),
  secret: System.get_env("AWS_SECRET"),
  bucket: System.get_env("S3_FILE_UPLOAD_BUCKET")

if config_env() == :prod do
  openai_key =
    System.get_env("OPENAI_KEY") ||
      raise """
      Environment variable OPENAI_KEY is missing.
      """

  openai_org_id =
    System.get_env("OPENAI_ORG_ID") ||
      raise """
      Environment variable OPENAI_ORG_ID is missing.
      """

  config :langchain, openai_key: openai_key
  config :langchain, openai_org_id: openai_org_id

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :portfolio, Portfolio.Repo,
    ssl: false,
    socket_options: maybe_ipv6,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host =
    System.get_env("PHX_HOST") ||
      raise """
      Environment variable PHX_HOST is missing.
      This is needed for your URLs to be generated properly.
      Set it to your domain name. eg 'example.com' or 'subdomain.example.com'."
      """

  port = String.to_integer(System.get_env("PORT") || "4000")

  config :portfolio, PortfolioWeb.Endpoint,
    server: true,
    url: [host: host, port: 80],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
