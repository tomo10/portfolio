defmodule PortfolioWeb.AdminJobsLive do
  use PortfolioWeb, :live_view
  import PortfolioWeb.AdminLayoutComponent
  alias PetalFramework.Components.AlpineComponents
  alias PetalFramework.Components.DataTable

  @data_table_opts [
    default_order: [
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    ],
    default_limit: 20,
    default_pagination_type: :page
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Jobs")}
  end

  @impl true
  def handle_params(params, url, socket) do
    {jobs, meta} = DataTable.search(Oban.Job, params, @data_table_opts)
    {:noreply, assign(socket, %{jobs: jobs, meta: meta, url: url})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.admin_layout current_page={:admin_jobs} current_user={@current_user}>
      <.page_header title={@page_title} />
      <AlpineComponents.js_setup />

      <.data_table meta={@meta} items={@jobs}>
        <:col field={:id} sortable /><:col field={:state} sortable filterable={[:=~]} /><:col
          field={:queue}
          sortable
          filterable={[:=~]}
        />
        <:col :let={job} field={:args}>
          <AlpineComponents.truncate lines={1}>
            <%= inspect(job.args) %>
          </AlpineComponents.truncate>
        </:col>
        <:col :let={job} field={:attempt}>
          <%= job.attempt %>/<%= job.max_attempts %>
        </:col>
        <:col :let={job} field={:errors}>
          <%= if job.state in ["completed", "discarded", "cancelled"] do %>
            NA
          <% else %>
            <AlpineComponents.truncate lines={2}>
              <%= inspect(job.errors) %>
            </AlpineComponents.truncate>
          <% end %>
        </:col>
        <:col :let={job} label="">
          <div class="flex gap-2">
            <%= if job.state == "retryable" do %>
              <.button size="sm" label="Retry" color="white" phx-click="retry" phx-value-id={job.id} />
            <% end %>

            <%= if !Enum.member?(["cancelled", "discarded", "completed"], job.state) do %>
              <.button
                size="sm"
                label="Cancel"
                color="danger"
                phx-click="cancel"
                phx-value-id={job.id}
              />
            <% end %>
          </div>
        </:col>
      </.data_table>
    </.admin_layout>
    """
  end

  def render_name(item) do
    item.name <> " " <> item.email
  end

  @impl true
  def handle_event("retry", %{"id" => oban_id}, socket) do
    Oban.retry_job(String.to_integer(oban_id))

    socket =
      socket
      |> put_flash(:success, "Job retrying")
      |> push_navigate(to: ~p"/admin/jobs")

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", %{"id" => oban_id}, socket) do
    Oban.cancel_job(String.to_integer(oban_id))

    socket =
      socket
      |> put_flash(:success, "Job cancelled")
      |> push_navigate(to: ~p"/admin/jobs")

    {:noreply, socket}
  end
end
