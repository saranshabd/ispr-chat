defmodule ChatApiWeb.Endpoint do
  use Sentry.PlugCapture
  use Phoenix.Endpoint, otp_app: :chat_api
  use Appsignal.Phoenix

  @session_options [
    store: :cookie,
    key: "_chat_api_key",
    signing_salt: System.get_env("COOKIE_SIGNING_SALT"),
    encryption_salt: System.get_env("COOKIE_ENCRYPTION_SALT")
  ]

  socket("/socket", ChatApiWeb.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false
  )

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :chat_api,
    gzip: true,
    headers: [{"cache-control", "max-age=31536000"}]
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :chat_api)
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Sentry.PlugContext)

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)

  base_allowed_origins = [~r{^https?://(.*.?)papercups.io$}]
  allowed_origins = String.split(System.get_env("ALLOWED_ORIGINS"), ",")
  plug(Corsica,
    origins: base_allowed_origins ++ allowed_origins,
    allow_credentials: true,
    allow_headers: ["Content-Type", "Authorization"],
    log: [rejected: :error, invalid: :warn, accepted: :debug]
  )

  plug(ChatApiWeb.Router)
end
