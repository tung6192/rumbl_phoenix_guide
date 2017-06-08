defmodule Rumbl.PageControllerTest do
  use Rumbl.ConnCase

  @tag pageindex: "yep"
  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Rumb.io"
  end
end
