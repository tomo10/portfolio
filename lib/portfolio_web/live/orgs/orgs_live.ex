defmodule PortfolioWeb.OrgsLive do
  @moduledoc """
  List all orgs for the current_user.
  """
  use PortfolioWeb, :live_view
  alias Portfolio.Orgs
  alias Portfolio.Orgs.Org

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_invitations(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New organization"))
    |> assign(:org, %Org{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Organizations"))
    |> assign(:org, nil)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.layout current_page={:orgs} current_user={@current_user} type="sidebar">
      <.container class="py-16">
        <.h2><%= gettext("Listing organizations for %{name}", name: user_name(@current_user)) %></.h2>

        <%= if @current_user.confirmed_at do %>
          <%= if @invitations != [] do %>
            <.alert with_icon class="max-w-md" color="warning" heading={gettext("New invitations")}>
              <div class="mb-2">
                <%= gettext("You have pending invitations.") %>
              </div>

              <.button link_type="live_redirect" color="success" to={~p"/app/users/org-invitations"}>
                <%= gettext("View invitations") %>
              </.button>
            </.alert>
          <% end %>

          <.h3 class="mt-8 !mb-5"><%= gettext("My organizations") %></.h3>

          <%= if Enum.all?([@orgs, @invitations], &Enum.empty?/1) do %>
            <.alert
              with_icon
              class="max-w-sm mb-5"
              heading={gettext("You don't belong to any organizations")}
            >
              <%= gettext("Create your first organization by clicking the button below.") %>
            </.alert>
          <% end %>

          <div class="grid grid-cols-1 gap-8 md:grid-cols-2 xl:grid-cols-4">
            <%= if @orgs != [] do %>
              <%= for org <- @orgs do %>
                <.link
                  navigate={~p"/app/org/#{org.slug}"}
                  class="relative block w-full p-12 text-center text-gray-700 bg-gray-100 border border-gray-200 rounded-lg shadow dark:border-gray-700 dark:shadow-lg dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 dark:text-gray-400 dark:group-hover:text-gray-100"
                >
                  <Heroicons.building_office class="w-12 h-12 mx-auto" />

                  <span class="block mt-2 text-sm font-medium ">
                    <%= org.name %>
                  </span>
                </.link>
              <% end %>
            <% end %>

            <.link
              navigate={~p"/app/orgs/new"}
              class="relative block w-full p-12 text-center text-gray-500 border-2 border-gray-300 border-dashed rounded-lg dark:border-gray-700 hover:border-gray-400 dark:hover:text-gray-300 dark:hover:border-gray-600 hover:text-gray-900 dark:text-gray-400"
            >
              <Heroicons.plus class="w-12 h-12 mx-auto" />

              <span class="block mt-2 text-sm font-medium ">
                <%= gettext("Create a new organization") %>
              </span>
            </.link>
          </div>
        <% else %>
          <.alert color="warning" class="my-5" heading={gettext("Unconfirmed account")}>
            <%= if Util.present?(@invitations) do %>
              <div class="mb-2">
                <%= gettext(
                  "You have been invited to join %{org_names}. To create an organization or accept any invitations, please confirm your account first.",
                  org_names: Enum.join(Enum.map(@invitations, & &1.org.name), ", ")
                ) %>
              </div>
            <% else %>
              <%= gettext("Please confirm your account to create an organization.") %>
            <% end %>
          </.alert>
        <% end %>
      </.container>

      <%= if @live_action == :new do %>
        <.modal max_width="lg" title={@page_title}>
          <.live_component
            module={PortfolioWeb.OrgFormComponent}
            id={:new}
            action={@live_action}
            org={@org}
            return_to={~p"/app/orgs"}
            current_user={@current_user}
          />
        </.modal>
      <% end %>
    </.layout>
    """
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/app/orgs")}
  end

  defp assign_invitations(socket) do
    invitations = Orgs.list_invitations_by_user(socket.assigns.current_user)

    assign(socket, :invitations, invitations)
  end
end
