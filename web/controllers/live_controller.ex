defmodule DrabTestApp.LiveController do
  @moduledoc false
  
  use DrabTestApp.Web, :controller
  use Drab.Controller 

  require Logger

  def index(conn, _params) do
    users = ~w(Zdzisław Zofia Hendryk Stefan)
    render_live conn, "index.html", users: users, count: length(users)
  end

  def mini(conn, _params) do
    # render_live conn, "mini.html", list: ["A", "B"]
    render_live conn, "mini.html", class1: "btn", class2: "btn-primary", full_class: "", hidden: true, label: "default",
      list: [1,2,3]
  end

  defp render_live(conn, template, assigns) do
    r = render(conn, template, assigns)
    # IO.inspect(Phoenix.View.render_to_string DrabTestApp.LiveView, "index.html", assigns)
    # IO.inspect r.assigns
    r
  end

  def welcome(conn,params) do
    conn
      |> render_live "welcome.html", current_user: conn.assigns["current_user"]
  end
  def login(conn, _params) do
    conn = conn
      |> put_layout "drab.html"

    IO.puts "layout: " <>  inspect layout(conn)

    conn
      |>  render_live  "login.html", conn: conn
  end
end
