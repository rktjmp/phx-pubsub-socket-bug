defmodule StickyBugWeb.BugLive do
  use StickyBugWeb, :live_view

  def mount(_params, _session, socket) do
    # Process.sleep(400)
    {:ok, socket}
  end

  def handle_params(%{"name" => name}, _uri, socket) do
    # Notify.notify will fire off a pubsub broadcast, which ListenLive will
    # recieve and update the notification list.
    # Since these are independent views, I would expect the order of operation
    # to not matter.
    #
    StickyBugWeb.ListenLive.Notify.notify("Params hello to #{name}")
    #
    # Seems to be "race-y" in some way, so we fake a heavy page load
    # though in my app I observe this bug without doing any action in
    # handle params beyond adjusting some templates via @live_action
    #
    # It's unclear if this value is machine dependent, it does not appear at
    # 1ms, but does at 2+. If in doubt add a few 100ms.
    Process.sleep(10)
    socket = assign(socket, name: name)

    # Comment out the call above, and enable this call to see a "proper"
    # functioning system, click any of the buttons to see the notification log.
    # StickyBugWeb.ListenLive.Notify.notify("Params hello to #{name}")

    {:noreply, socket}
  end

  # When given no name given, route to a default
  def handle_params(_, _uri, socket) do
    socket = push_patch(socket, to: Routes.bug_path(socket, :index, "Esme"))
    # notify that we moved
    StickyBugWeb.ListenLive.Notify.notify("Defaulting hello to Esmerelda ")
    {:noreply, socket}
  end

  def handle_event("manual-trigger", _, socket) do
    StickyBugWeb.ListenLive.Notify.notify("Your dog is #{Enum.random(~w(Laika Lassie Yeller))}")
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-2">
      <div>
        <div class="mb-4 font-bold">
          Hello <%= @name %>
        </div>
        <ul class="space-y-2">
          <li>
            <a phx-click="manual-trigger" class="underline">Make notification (phx-click)</a>
          </li>
          <li>
            <%= live_patch("Say Hello to alice (patch)", to: Routes.bug_path(@socket, :index, "alice"), class: "underline") %>
          </li>
          <li>
            <%= live_patch("Say Hello to bob (patch)", to: Routes.bug_path(@socket, :index, "bob"), class: "underline") %>
          </li>
          <li>
            <%= live_redirect("Visit another page via redirect", to: Routes.other_path(@socket, :index), class: "underline") %>
          </li>
        </ul>
      </div>
    <div class="space-y-4 bg-slate-100 p-4">
      <div class="space-y-2">
        <h1>Bug 1</h1>
        <p>"statics is undefined" js exception</p>
        <ul class="list-disc list-outside pl-4">
          <li>Visit localhost:4000/bug/bob (refresh)</li>
          <li>Open console</li>
          <li>Click hello to alice (or bob)</li>
          <li>Click make notification</li>
        </ul>
        <p class="italic">I think this might occur because LV *thinks* it has rendered out the changes for the "hello".</p>
      </div>

      <div class="space-y-2">
        <h1>Bug 2</h1>
        <p>ListenLive doesn't re-render when it recieves patch notifications</p>
        <ul class="list-disc list-outside pl-4">
          <li>Visit localhost:4000/bug/bob (refresh)</li>
          <li>Click make notification</li>
          <li>Cilck hello to alice</li>
          <li>Cilck hello to bob</li>
          <li>Witness notifications *are* received by ListenLive in Elixirs log.</li>
          <li>Witness no new notifications are rendered by ListenLive in-page</li>
          <li>Cilck make notification</li>
          <li>Witness all notifications appear</li>
        </ul>
        <p class="italic">Lookout! Don't let bug 1 interfere with testing bug 2, if *nothing* is working, bug 1 probably occured while you had the console closed.</p>
      </div>
    </div>
    </div>
    """
  end
end
