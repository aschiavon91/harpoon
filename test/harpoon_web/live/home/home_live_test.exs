defmodule HarpoonWeb.HomeLiveTest do
  use HarpoonWeb.ConnCase

  alias Harpoon.Contexts.Requests

  test "should add session id when dont have", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: <<"/" <> uuid>>, flash: %{}}}} = live(conn, "/")
    assert Ecto.UUID.cast!(uuid)
  end

  test "should render when already wave session id", %{conn: conn} do
    sid = Ecto.UUID.generate()
    assert {:ok, %View{}, html} = live(conn, "/#{sid}")
    assert html =~ "Nothing captured yet"
    assert html =~ "You can start making your requests!"
    assert html =~ "http://localhost:4002/#{sid}"
  end

  test "should redirect to last received request if already have some", %{conn: conn} do
    %{sid: sid, requests: [_req1, req2]} = build_ctx()
    assert {:error, {:live_redirect, %{to: location, flash: %{}}}} = live(conn, "/#{sid}")
    assert location == "/#{sid}/#{req2.id}"
  end

  test "should render all request in aside menu", %{conn: conn} do
    %{sid: sid, requests: [req1 | _] = requests} = build_ctx()
    assert {:ok, view, _html} = live(conn, "/#{sid}/#{req1.id}")

    for req <- requests do
      assert view |> element("aside ul li ul a[href='/#{sid}/#{req.id}']") |> render()
    end
  end

  test "should render request details data when request is seleted", %{conn: conn} do
    %{sid: sid, requests: [req1 | _]} = build_ctx()
    assert {:ok, view, _html} = live(conn, "/#{sid}/#{req1.id}")

    assert view |> element("#request-details-table caption", "Request Details") |> render()

    for {key, value} <- Map.take(req1, ~w(id method path host remote_ip remote_port http_version body_length)) do
      assert view |> element("#request-details-table tbody tr .data-key-name", key) |> render()
      assert view |> element("#request-details-table tbody tr .data-value", to_string(value)) |> render()
    end

    assert view |> element("#cookies-table caption", "Cookies") |> render()

    for {key, value} <- req1.cookies do
      assert view |> element("#cookies-table tbody tr .data-key-name", key) |> render()
      assert view |> element("#cookies-table tbody tr .data-value", to_string(value)) |> render()
    end

    assert view |> element("table caption", "Headers") |> render()

    for {key, value} <- req1.headers do
      assert view |> element("#headers-table tbody tr .data-key-name", key) |> render()
      assert view |> element("#headers-table tbody tr .data-value", to_string(value)) |> render()
    end

    assert view |> element("#body-data", "Body") |> render()
    assert view |> element("#body-data code") |> render()
  end

  defp build_ctx do
    sid = Ecto.UUID.generate()

    request1_params = %{
      sid: sid,
      body: ~s/{"data": "test"}/,
      cookies: %{"_sid" => 123},
      headers: %{"content-type" => "application/json"},
      host: "http://test.com",
      http_version: "HTTP/1.1",
      path: "/testing",
      method: "post",
      remote_ip: "127.0.0.1",
      remote_port: "50000",
      body_length: 1000
    }

    request2_params = %{
      sid: sid,
      body: nil,
      cookies: %{"_sid" => 123},
      headers: %{"content-type" => "application/json"},
      host: "http://test.com",
      http_version: "HTTP/1.1",
      path: "/testing",
      method: "get",
      remote_ip: "127.0.0.1",
      remote_port: "50000",
      body_length: 0,
      query_params: %{"test" => 123}
    }

    {:ok, {:created, req1}} = Requests.create(request1_params)
    {:ok, {:created, req2}} = Requests.create(request2_params)

    %{sid: sid, requests: [req1, req2]}
  end
end
