defmodule MyAgent do

  def start_link(func) do
    spawn_link(__MODULE__, :agent_loop, func.())
  end

  def get(pid, func) do
    send(pid, {:get, func, self})

    receive do
      {:get, response} ->
        response
    after 5000 ->
      IO.puts "timed out"
    end
  end

  def update(pid, func) do
    send(pid, {:update, func})
    :ok
  end

  defp agent_loop(state) do
    receive do
      {:get, func, from} ->
        response = func.(state)
        send(from, {:get, response})
      {:update, func} ->
        state = func.(state)
    end
    agent_loop(state)
  end

end
