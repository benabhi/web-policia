# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :policia,
  ecto_repos: [Policia.Repo],
  generators: [timestamp_type: :utc_datetime]

config :policia, :webpage,
  slider: true,
  theme: "blue"

# TODO: Dividir luego bien las configuraciones
config :policia, :institution,
  name: "Policía de Río Negro",
  short_name: "Policía RN",
  slogan: "Protegiendo a nuestra comunidad",
  domain: "policia.rionegro.gov.ar",
  address: "Roca 243, Viedma, Río Negro, Argentina",
  phone: "+54 (2920) 423045",
  emails: ["contacto@policia.rionegro.gov.ar", "info@policia.rionegro.gov.ar"],
  social_links: [
    %{name: "X", url: "https://x.com/policiarionegro"},
    %{
      name: "Facebook",
      url:
        "https://www.facebook.com/p/Jefatura-de-Polic%C3%ADa-de-R%C3%ADo-Negro-100064633034065/?locale=es_LA&_rdr"
    },
    %{name: "Instagram", url: "https://www.instagram.com/policiarionegro/"},
    %{
      name: "YouTube",
      url: "https://www.youtube.com/user/policiarionegro/videos"
    }
  ]

# Configures the endpoint
config :policia, PoliciaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: PoliciaWeb.ErrorHTML, json: PoliciaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Policia.PubSub,
  live_view: [signing_salt: "H8yx4h3L"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :policia, Policia.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  policia: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  policia: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Añadir la configuración para Scrivener
config :scrivener_ecto, repo: Policia.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
