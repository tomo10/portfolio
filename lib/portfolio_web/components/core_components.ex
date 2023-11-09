defmodule PortfolioWeb.CoreComponents do
  use Phoenix.Component
  use PortfolioWeb, :verified_routes
  use PetalComponents
  use PetalFramework

  # SETUP_TODO
  # This module relies on the following images. Replace these images with your logos.
  # We created a Figma file to easily create and import these assets: https://www.figma.com/community/file/1139155923924401853
  # /priv/static/images/logo_dark.svg
  # /priv/static/images/logo_light.svg
  # /priv/static/images/logo_icon_dark.svg
  # /priv/static/images/logo_icon_light.svg
  # /priv/static/images/favicon.png
  # /priv/static/images/open-graph.png

  @doc "Displays your full logo. "

  attr :class, :string, default: "h-10"
  attr :variant, :string, default: "both", values: ["dark", "light", "both"]

  def logo(assigns) do
    assigns = assign_new(assigns, :logo_file, fn -> "logo_#{assigns[:variant]}.svg" end)

    ~H"""
    <%= if Enum.member?(["light", "dark"], @variant) do %>
      <p class="font-sans hover:bold">THCE</p>
    <% else %>
      <p class="font-sans hover:bold">THCE</p>
    <% end %>
    """
  end

  @doc "Displays just the icon part of your logo"

  attr :class, :string, default: "h-9 w-9"
  attr :variant, :string, default: "both", values: ["dark", "light", "both"]

  def logo_icon(assigns) do
    assigns = assign_new(assigns, :logo_file, fn -> "logo_icon_#{assigns[:variant]}.svg" end)

    ~H"""
    <%= if Enum.member?(["light", "dark"], @variant) do %>
      <p>THCE</p>
    <% else %>
      <p>THCE</p>
    <% end %>
    """
  end

  def logo_for_emails(assigns) do
    ~H"""
    <img height="60" src={Portfolio.config(:logo_url_for_emails)} />
    """
  end

  @doc """
  A kind of proxy layout allowing you to pass in a user. Layout components should have little knowledge about your application so this is a way you can pass in a user and it will build a lot of the attributes for you based off the user.

  Ideally you should modify this file a lot and not touch the actual layout components like "sidebar_layout" and "stacked_layout".
  If you're creating a new layout then duplicate "sidebar_layout" or "stacked_layout" and give it a new name. Then modify this file to allow your new layout. This way live views can keep using this component and simply switch the "type" attribute to your new layout.
  """
  attr :type, :string, default: "sidebar", values: ["sidebar", "stacked", "public"]
  attr :current_page, :atom, required: true
  attr :current_user, :map, default: nil
  attr :public_menu_items, :list
  attr :main_menu_items, :list
  attr :avatar_src, :string
  attr :current_user_name, :string
  attr :sidebar_title, :string, default: nil
  attr :home_path, :string
  attr :container_max_width, :string, default: "lg", values: ["sm", "md", "lg", "xl", "full"]
  slot :inner_block
  slot :top_right
  slot :logo

  def layout(assigns) do
    ~H"""
    <%= case @type do %>
      <% "sidebar" -> %>
        <.sidebar_layout {assigns}>
          <:logo>
            <.logo class="h-8 transition-transform duration-300 ease-out transform hover:scale-105" />
          </:logo>
          <:top_right>
            <.color_scheme_switch />
          </:top_right>
          <%= render_slot(@inner_block) %>
        </.sidebar_layout>
      <% "stacked" -> %>
        <.stacked_layout {assigns}>
          <:logo>
            <div class="flex items-center flex-shrink-0 w-24 h-full">
              <div class="hidden lg:block">
                <.logo class="h-8" />
              </div>
              <div class="block lg:hidden">
                <.logo_icon class="w-auto h-8" />
              </div>
            </div>
          </:logo>
          <:top_right>
            <.color_scheme_switch />
          </:top_right>
          <%= render_slot(@inner_block) %>
        </.stacked_layout>
    <% end %>
    """
  end

  @doc """
  Checks if a ueberauth provider has been enabled with the correct environment variables

  ## Examples

      iex> auth_provider_loaded?("google")
      iex> true
  """
  def auth_provider_loaded?(provider) do
    case provider do
      "google" ->
        get_in(Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth), [:client_id])

      "github" ->
        get_in(Application.get_env(:ueberauth, Ueberauth.Strategy.Github.OAuth), [:client_id])

      "passwordless" ->
        Portfolio.config(:passwordless_enabled)
    end
  end

  # Shows a line with some text in the middle of the line. eg "Or login with"
  attr :or_text, :string

  def or_break(assigns) do
    ~H"""
    <div class="relative my-5">
      <div class="absolute inset-0 flex items-center">
        <div class="w-full border-t border-gray-300 dark:border-gray-600"></div>
      </div>
      <div class="relative flex justify-center text-sm">
        <span class="px-2 text-gray-500 bg-white dark:bg-gray-800">
          <%= @or_text %>
        </span>
      </div>
    </div>
    """
  end

  attr :li_class, :string, default: ""
  attr :a_class, :string, default: ""
  attr :menu_items, :list, default: [], doc: "list of maps with keys :method, :path, :label"

  def list_menu_items(assigns) do
    ~H"""
    <%= for menu_item <- @menu_items do %>
      <li class={@li_class}>
        <.link
          href={menu_item.path}
          class={@a_class}
          method={if menu_item[:method], do: menu_item[:method], else: nil}
        >
          <%= menu_item.label %>
        </.link>
      </li>
    <% end %>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="flex gap-3 my-3 text-sm leading-6 phx-no-feedback:hidden text-rose-600">
      <Heroicons.exclamation_circle mini class="mt-0.5 h-5 w-5 flex-none fill-rose-500" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(PortfolioWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(PortfolioWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  @doc """
  Use for when you want to combine all form errors into one message (maybe to display in a flash)
  """
  def combine_changeset_error_messages(changeset) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    Enum.map_join(errors, "\n", fn {key, errors} ->
      "#{Phoenix.Naming.humanize(key)}: #{Enum.join(errors, ", ")}\n"
    end)
  end
end
