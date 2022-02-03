defmodule StickyBugWeb.ListenLive do
  @moduledoc """
  Subs to topic and displays notifications on events.
  Render as nested view in layout.
  The intended usecase is, you have one ListenLive view in your app that manages
  all notifications (or all notifications of a type).
  """

  defmodule Notify do
    @moduledoc """
    Manages subscribing to notification topic and broadcasting on that topic.

    Lives in ListenLive for less-file spawl in demo.
    """

    @doc """
    Subscribe caller to notification topic
    """
    def subscribe() do
      Phoenix.PubSub.subscribe(StickyBug.PubSub, topic())
    end

    @doc """
    Broadcast {:notification, %{id: <generated>, message: message}}
    """
    def notify(message) do
      Phoenix.PubSub.broadcast(
        StickyBug.PubSub,
        topic(),
        {:notification, %{id: System.unique_integer(), message: message}}
      )
    end

    defp topic() do
      "my-demo-topic"
    end
  end

  use StickyBugWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    socket =
      case connected?(socket) do
        true ->
          :ok = Notify.subscribe()
          assign(socket, subscribed: true)

        false ->
          assign(socket, subscribed: false)
      end

    socket = assign(socket, notifications: [])

    {:ok, socket, layout: false}
  end

  # receive a notification broadcast and store it in our notification list
  def handle_info({:notification, %{id: id, message: message}}, socket) do
    log("got notification #{id} = #{message}")
    socket =
      update(socket, :notifications, fn notis ->
        [%{id: id, message: message} | notis]
      end)

    {:noreply, socket}
  end

  def handle_event("clear-one", %{"id" => id}, socket) do
    log("clear #{id}")
    {id, _} = Integer.parse(id)

    socket =
      update(socket, :notifications, fn notis ->
        Enum.reject(notis, fn n -> n.id == id end)
      end)

    {:noreply, socket}
  end

  def handle_event("clear-all", _, socket) do
    socket =
      assign(socket, :notifications, [])

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-2">
      <p>
        Listen <%= inspect self() %> subscribed: <%= @subscribed %>
      </p>
      <a class="underline" phx-click="clear-all">discard all notifications</a>
      <ul class="list-disc list-inside">
        <%= for noti <- @notifications do %>
          <li><%= noti.id %>:: <%= noti.message %> <a phx-click="clear-one" class="text-lg underline" phx-value-id={noti.id}>&times;</a></li>
        <% end %>
      </ul>
    </div>
    """
  end

  defp log(message) do
    Logger.warn("ListenLive #{inspect self()} :: #{message}")
  end
end
