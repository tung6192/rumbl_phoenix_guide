defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase
  alias Rumbl.Auth
  import Rumbl.TestHelpers

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Rumbl.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when the current_user exits", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Rumbl.User{})
      |> Auth.authenticate_user([])
  end

  test "login puts the user in the session", %{conn: conn} do
    user = %Rumbl.User{id: 123}
    login_conn =
      conn
      |> Auth.login(user)
      |> send_resp(:ok, "")

    next_conn = get login_conn, page_path(login_conn, :index)
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout and drop the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get logout_conn, page_path(logout_conn, :index)
    refute get_session(next_conn, :user_id) == 123
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)

    assert conn.assigns.current_user == nil
  end
end