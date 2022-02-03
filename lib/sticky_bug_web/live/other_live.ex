defmodule StickyBugWeb.OtherLive do
  @moduledoc """
  I just exist as another page to visit, to see if notifications stick around
  """
  use StickyBugWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end


  def render(assigns) do
    ~H"""
    <div>
      <div>
        I am the other page. I exist to demostrate the sticky nature of the notifications.
      </div>
    <ul>
      <li>
        <%= live_patch("Go back to bob", to: Routes.bug_path(@socket, :index, "bob")) %>
      </li>
      <li>
        <%= live_patch("Go back to alice", to: Routes.bug_path(@socket, :index, "alice")) %>
      </li>
    </ul>
    </div>
    """
  end
end
