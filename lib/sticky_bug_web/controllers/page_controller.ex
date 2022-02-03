defmodule StickyBugWeb.PageController do
  use StickyBugWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
