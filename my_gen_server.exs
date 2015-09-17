defmodule MyGenServer do
  defmacro __using__(_) do
    quote do

      def start_server(initial_state) do
        message_loop(initial_state)
      end

      defp message_loop(state) do
        receive do
          {:call, args, from} ->
            IO.puts "Received call with args: #{inspect args}"
            receive_call(args, state, from) |> message_loop
          {:cast, args} ->
            IO.puts "Received cast with args: #{inspect args}"
            receive_cast(args, state) |> message_loop
        end
      end

      defp receive_call(args, state, from) do
        {:reply, response, new_state} = apply(__MODULE__, :handle_call, [args, from, state])
        send(from, {:reply, response})
        new_state
      end

      defp receive_cast(args, state) do
        {:noreply, new_state} = apply(__MODULE__, :handle_cast, [args, state])
        new_state
      end

    end
  end

  def start_link(module, initial_state) do
    IO.puts "starting link in module: #{inspect module}; state: #{inspect initial_state}"
    pid = spawn(module, :start_server, [initial_state])
    {:ok, pid}
  end

  def call(pid, msg, timeout \\ 5000) do
    send(pid, {:call, msg, self})

    receive do
      {:reply, response} ->
        response
    after timeout ->
      IO.puts "call to #{inspect pid} timed out after #{timeout} ms"
    end
  end

  def cast(pid, msg) do
    send(pid, {:cast, msg})
    :ok
  end
end

defmodule Counter do
  use MyGenServer

  def start_link do
    MyGenServer.start_link(__MODULE__, 0)
  end

  def increment(pid) do
    MyGenServer.call(pid, :increment)
  end

  def async_increment(pid) do
    MyGenServer.cast(pid, :increment)
  end

  def decrement(pid) do
    MyGenServer.call(pid, :decrement) # unhandled call
  end

  ###

  def handle_call(:increment, _from, count) do
    new = count + 1
    {:reply, new, new}
  end

  def handle_cast(:increment, count) do
    {:noreply, count + 1}
  end
end