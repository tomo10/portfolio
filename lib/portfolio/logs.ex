defmodule Portfolio.Logs do
  @moduledoc """
  A context file for CRUDing logs
  """

  import Ecto.Query, warn: false
  alias PetalFramework.Extensions.Ecto.QueryExt
  alias Portfolio.Logs.Log
  alias Portfolio.Repo

  require Logger

  # Logs allow you to keep track of user activity.
  # This helps with both analytics and customer support (easy to look up a user and see what they've done)
  # If you don't want to store logs on your db, you could rewrite this file to send them to a 3rd
  # party service like https://www.datadoghq.com/

  def get(id), do: Repo.get(Log, id)

  def create(attrs \\ %{}) do
    case %Log{}
         |> Log.changeset(attrs)
         |> Repo.insert() do
      {:ok, log} ->
        PortfolioWeb.Endpoint.broadcast("logs", "new-log", log)
        {:ok, log}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def log(action, params) do
    build(action, params)
    |> create()
  end

  def log_async(action, params) do
    Portfolio.BackgroundTask.run(fn ->
      log(action, params)
    end)
  end

  @doc """
  Builds a log from the given action and params.

  Examples:

      Portfolio.Logs.log("orgs.create_invitation", %{
        user: socket.assigns.current_user,
        target_user_id: nil,
        org_id: org.id,
      })

      # When one user performs an action on another user:
      Portfolio.Logs.log("orgs.delete_member", %{
        user: socket.assigns.current_user,
        target_user: member_user,
        org_id: org.id,
      })
  """
  def build(action, params) do
    user_id = if params[:user], do: params.user.id, else: params[:user_id]
    org_id = if params[:org], do: params.org.id, else: params[:org_id]

    target_user_id =
      if params[:target_user], do: params.target_user.id, else: params[:target_user_id]

    %{
      user_id: user_id,
      org_id: org_id,
      target_user_id: target_user_id,
      action: action,
      user_role: params[:user_role] || if(params.user.is_admin, do: "admin", else: "user"),
      metadata: params[:metadata] || %{}
    }
  end

  @doc """
  Create a log as a multi.

  Examples:

      Ecto.Multi.new()
      |> Ecto.Multi.insert(:post, changeset)
      |> Logs.multi(fn %{post: post} ->
        Logs.build("post.insert", %{user: user, metadata: %{post_id: post.id}})
      end)
  """
  def multi(multi, fun) when is_function(fun) do
    multi
    |> Ecto.Multi.insert(:log, fn previous_multi_results ->
      log_params = fun.(previous_multi_results)
      Log.changeset(%Log{}, log_params)
    end)
    |> Ecto.Multi.run(:broadcast_log, fn _repo, %{log: log} ->
      PortfolioWeb.Endpoint.broadcast("logs", "new-log", log)
      {:ok, nil}
    end)
  end

  def exists?(params) do
    Log
    |> QueryBuilder.where(params)
    |> Portfolio.Repo.exists?()
  end

  def get_last_log_of_user(user) do
    Portfolio.Logs.LogQuery.by_user(user.id)
    |> Portfolio.Logs.LogQuery.order_by(:newest)
    |> QueryExt.limit(1)
    |> Portfolio.Repo.one()
  end
end
