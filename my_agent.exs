defmodule MyAgent do

  def start_link(func) do
    spawn_link(__MODULE__, :agent_loop, func.())
  end

  def get(pid, func) do
    send(pid, {:get, func, self})

    receive do
      {:response, response} ->
        response
    after 5000 ->
      IO.puts "timed out"
    end
  end

  def update(pid, func) do
    send(pid, {:update, func})
    :ok
  end

  def get_and_update(pid, func) do
    send(pid, {:get_and_update, func, self})

    receive do
      {:response, response} ->
        response
    after 5000 ->
      IO.puts "timed out"
    end
  end

  defp agent_loop(state) do
    receive do
      {:get, func, from} ->
        response = func.(state)
        send(from, {:response, response})
      {:update, func} ->
        state = func.(state)
      {:get_and_update, func, from} ->
        {response, state} = func.(state)
        send(from, {:response, response})
    end
    agent_loop(state)
  end

end
