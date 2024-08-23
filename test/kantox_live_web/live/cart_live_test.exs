defmodule SuperMarkexWeb.CartLive.IndexTest do
  use SuperMarkexWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  defp root_path(conn), do: live(conn, ~p"/")

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = root_path(conn)
    assert disconnected_html =~ "Shopping Carts"
    assert render(page_live) =~ "Shopping Carts"
  end

  test "create a new cart", %{conn: conn} do
    {:ok, view, _html} = root_path(conn)
    assert render(view) =~ "Create New Cart"
    view |> element("button", "Create New Cart") |> render_click()
    assert render(view) =~ "Cart"
  end

  test "add item to cart", %{conn: conn} do
    {:ok, view, _html} = root_path(conn)
    view |> element("button", "Create New Cart") |> render_click()

    view
    |> element("button[phx-value-product-code='GR1'][phx-value-action='increase']")
    |> render_click()

    assert render(view) =~ "Green tea"
    assert render(view) =~ "£3.11"
  end

  test "remove item from cart", %{conn: conn} do
    {:ok, view, _html} = root_path(conn)
    view |> element("button", "Create New Cart") |> render_click()

    view
    |> element("button[phx-value-product-code='GR1'][phx-value-action='increase']")
    |> render_click()

    assert render(view) =~ "Green tea"
    assert render(view) =~ "1"

    view
    |> element("button[phx-value-product-code='GR1'][phx-value-action='decrease']")
    |> render_click()

    assert render(view) =~ "£0.00"
  end

  test "clear cart", %{conn: conn} do
    {:ok, view, _html} = root_path(conn)
    view |> element("button", "Create New Cart") |> render_click()

    view
    |> element("button[phx-value-product-code='GR1'][phx-value-action='increase']")
    |> render_click()

    view
    |> element("button[phx-value-product-code='SR1'][phx-value-action='increase']")
    |> render_click()

    assert render(view) =~ "Green tea"
    assert render(view) =~ "1"
    assert render(view) =~ "Strawberries"
    assert render(view) =~ "1"
    view |> element("button[phx-click='delete-cart']") |> render_click()
    refute render(view) =~ "Green tea"
    refute render(view) =~ "Strawberries"
  end

  test "calculate total", %{conn: conn} do
    {:ok, view, _html} = root_path(conn)
    view |> element("button", "Create New Cart") |> render_click()

    view
    |> element("button[phx-value-product-code='GR1'][phx-value-action='increase']")
    |> render_click()

    view
    |> element("button[phx-value-product-code='SR1'][phx-value-action='increase']")
    |> render_click()

    assert render(view) =~ "£8.11"

    view
    |> element("button[phx-value-product-code='CF1'][phx-value-action='increase']")
    |> render_click()

    assert render(view) =~ "£19.34"
  end
end

