defmodule MyTask do

  def async(func) do
    spawn_link(__MODULE__, :start_task, [func, self])
  end

  def await(pid) do
    receive do
      {:task_done, pid, result} ->
        result
    after 5000 ->
      IO.puts "timed out"
    end
  end

  def start_task(func, from) do
    result = func.()
    send(from, {:task_done, self, result})
  end

end
