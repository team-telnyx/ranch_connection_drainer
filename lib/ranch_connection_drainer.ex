defmodule RanchConnectionDrainer do
  @moduledoc """
  Drain connections before shutting down.

  If your Phoenix endpoint is `MyPhoenix.Endpoint`, and you are running your server on http, then the correct value is `MyPhoenix.Endpoint.HTTP`. If you are running https, then you would use `MyPhoenix.Endpoint.HTTPS`.

  To add this to your application, simply add `{RanchConnectionDrainer, [ranch_ref: MyPhoenix.Endpoint.HTTP, shutdown: 10_000]}` to the line *below* `MyPhoenix.Endpoint` in your Application file.
  """

  use GenServer

  def child_spec(options) when is_list(options) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [Keyword.fetch!(options, :ranch_ref)]},
      shutdown: Keyword.fetch!(options, :shutdown)
    }
  end

  def start_link(ranch_ref) do
    GenServer.start_link(__MODULE__, ranch_ref)
  end

  def init(ranch_ref) do
    Process.flag(:trap_exit, true)
    {:ok, ranch_ref}
  end

  def terminate(_reason, ranch_ref) do
    :ok = :ranch.suspend_listener(ranch_ref)
    :ok = :ranch.wait_for_connections(ranch_ref, :==, 0, :infinity)
  end
end
