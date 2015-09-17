# MyGenServer
Understanding Elixir processes and OTP by making a basic GenServer implementation

Behaves like GenServer (without probably 99% of the functionality)

eg...
```elixir
defmodule MyThingamajig
  use MyGenServer
  
  def handle_call({:message, args}, _from, state) do
    {:reply, response, state}
  end
  
  def handle_cast({:message, args}, state) do
    {:noreply, state}
  end
end

{:ok, pid} = MyGenServer.start_link(module, state)
MyGenServer.call(pid, {:message, args})
MyGenServer.cast(pid, {:message, args})
```

Basic counter I made using MyGenServer:
```elixir
{:ok, pid} = Counter.start_link
Counter.increment(pid) #=> 1
Counter.async_increment(pid) # returns nothing (non-blocking)
```
