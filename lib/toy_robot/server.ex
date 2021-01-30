defmodule ToyRobot.Server do
  use GenServer

  alias ToyRobot.Logic

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    initial_state = Logic.new()
    {:ok, initial_state}
  end

  def current_state(server_pid) do
    GenServer.call(server_pid, :get_state)
  end

  def update_state(new_state, server_pid) do
    GenServer.call(server_pid, {:update, new_state})
  end

  def do_command(cmd, server_pid) do
    state = current_state(server_pid)
    apply(Logic, cmd, [state])
    |> update_state(server_pid)
    :ok
  end

  def place(server_pid, args) do
    [x, y, face] = args
    Logic.place(x, y, face)
    |> update_state(server_pid)
  end

  def report(server_pid) do
    state = current_state(server_pid)
    Logic.report(state)
  end

  def move(server_pid) do
    do_command(:move, server_pid)
  end

  def left(server_pid) do
    do_command(:left, server_pid)
  end

  def right(server_pid) do
    do_command(:right, server_pid)
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update, new_state}, _from, state) do
    {:reply, state, new_state}
  end
end
