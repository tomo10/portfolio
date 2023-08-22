defmodule PortfolioWeb.LogsLive do
  @moduledoc """
  A component to display a list of logs. Logs are actions performed by users, and can help you discover how your application is used.
  """
  use PortfolioWeb, :live_view
  alias Portfolio.Repo

  alias Portfolio.Logs.Log
  alias Portfolio.Logs.LogQuery

  alias PortfolioWeb.LogsLive.LogDataTableSettings
  alias PortfolioWeb.LogsLive.SearchChangeset

  import PortfolioWeb.AdminLayoutComponent

  @log_preloads [
    :user,
    :target_user
  ]

  @page_length 20

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      PortfolioWeb.Endpoint.subscribe("logs")
    end

    socket =
      assign(
        socket,
        %{
          page_title: "Logs",
          load_more: false,
          action: "",
          limit: @page_length
        }
      )
      |> assign_search_form(params)

    {:ok, set_logs(socket, params)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign_search_form(params)
      |> set_logs(params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"search" => search_params}, socket) do
    params = build_filter_params(socket.assigns.meta, search_params)
    {:noreply, push_patch(socket, to: ~p"/admin/logs?#{params}")}
  end

  @impl true
  def handle_event("load-more", params, socket) do
    socket =
      socket
      |> update(:limit, fn limit -> limit + @page_length end)
      |> set_logs(params)

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{
          topic: "logs",
          event: "new-log",
          payload: log
        },
        socket
      ) do
    if socket.assigns.search_form.source.changes[:enable_live_logs] do
      log = Repo.preload(log, @log_preloads)

      {:noreply, assign(socket, logs: [log | socket.assigns.logs])}
    else
      {:noreply, socket}
    end
  end

  def set_logs(socket, params) do
    case SearchChangeset.validate(socket.assigns.search_form.source) do
      {:ok, search_attrs} ->
        query =
          Log
          |> LogQuery.join_users()
          |> LogQuery.by_action(search_attrs[:action])
          |> LogQuery.limit(socket.assigns.limit)
          |> LogQuery.preload(@log_preloads)

        query =
          if search_attrs[:user_id] do
            LogQuery.by_user(query, search_attrs.user_id)
          else
            query
          end

        {logs, meta} =
          search(query, params,
            default_limit: socket.assigns.limit,
            for: LogDataTableSettings
          )

        assign(socket, %{
          logs: logs,
          meta: meta,
          load_more: length(logs) >= socket.assigns.limit
        })

      {:error, changeset} ->
        assign(socket, %{
          search_form: to_form(changeset, as: :search),
          logs: []
        })
    end
  end

  defp maybe_add_emoji("register"), do: "🥳"
  defp maybe_add_emoji("sign_in"), do: "🙌"
  defp maybe_add_emoji("delete_user"), do: "💀"
  defp maybe_add_emoji("confirm_new_email"), do: "📧"
  defp maybe_add_emoji("orgs.create"), do: "🏢"
  defp maybe_add_emoji("impersonate_user"), do: "👀"
  defp maybe_add_emoji("restore_impersonator"), do: "🙈"
  defp maybe_add_emoji(_), do: ""

  defp assign_search_form(socket, params) do
    assign(socket, search_form: to_form(SearchChangeset.build(params), as: :search))
  end
end
