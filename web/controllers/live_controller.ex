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
    #unf(conn)
    conn
      |> unf
      |>  render_live  "login.html", conn: conn
  end

  def unf(conn, assigns \\[]) do


    controller = Phoenix.Controller.controller_module(conn)

    if Enum.member?(controller.__info__(:functions), {:__drab__, 0}) do
      controller_and_action = Phoenix.Token.sign(conn, "controller_and_action", 
                              [__controller: controller, 
                               __action: Phoenix.Controller.action_name(conn), 
                               __assigns: assigns])

      commander = controller.__drab__()[:commander]
        broadcast_topic = topic(commander.__drab__().broadcasting, controller, conn.request_path)

      access_session = commander.__drab__().access_session
        session = access_session 
          |> Enum.map(fn x -> {x, Plug.Conn.get_session(conn, x)} end) 
          |> Enum.into(%{})
        # Logger.debug("**** #{inspect session}")
  
          session_token = Drab.Core.tokenize_store(conn, session)
  
  
      s = "Drab.run('<%= controller_and_action %>', '<%= drab_session_token %>', '<%= broadcast_topic %>')"
      templ = EEx.eval_string(s,[
        controller_and_action: controller_and_action,
        drab_session_token: session_token,
        broadcast_topic: broadcast_topic
        ])
      {:safe, s} = Phoenix.HTML.raw( "#{templ}" )
      IO.puts "generated some thingy" <> inspect s
      assign(conn, :thingy, s)
    else
      ""
    end
  end
  defp topic(:same_url, _, path), do: "same_url:#{path}"
  defp topic(:same_controller, controller, _), do: "controller:#{inspect(controller)}"
  defp topic(topic, _, _) when is_binary(topic), do: "topic:#{topic}"
end
