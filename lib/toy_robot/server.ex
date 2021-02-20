defmodule ToyRobot.Server do
@moduledoc """
The ToyRobot.Server module manages state for the ToyRobot simulation.

The `ToyRobot.Logic` module is aliased to provide the logic for valid moves and
rules for state changes.
"""

  use GenServer, restart: :transient

  alias ToyRobot.Logic

  @doc """
  Starts a supervised process instance of the `ToyRobot.Server`
  """
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    initial_state = Logic.new()
    {:ok, initial_state}
  end

  @doc """
  Sync call to the server that matches on :get_state
  Returns current state of the toyrobot as a `%ToyRobot.Logic{x: x, y: y, face: face}` struct.
  """
  def current_state(server_pid) do
    GenServer.call(server_pid, :get_state)
  end

  @doc """
  Sync call to the server that matches on :update
  """
  def update_state(new_state, server_pid) do
    GenServer.call(server_pid, {:update, new_state})
  end

  @doc """
  - Gets current state from `ToyRobot.Server.current_state/1`.
  - Calls `ToyRobot.Logic` to get an updated value for the state then
  delegates acutal update to `ToyRobot.Server.update_state/2`
  - Common code to handle each of the `["MOVE", "LEFT", "RIGHT"]` commands.
  """
  def do_command(cmd, server_pid) do
    state = current_state(server_pid)
    apply(Logic, cmd, [state])
    |> update_state(server_pid)
    :ok
  end

  @doc """
  Specific handler for the `"PLACE y,y,facing"` command.
  Deligates to `ToyRobot.Logic.place/3` and performs a sync
  call to `ToyRobot.Server.update_state/2`
  """
  def place(server_pid, args) do
    [x, y, face] = args
    Logic.place(x, y, face)
    |> update_state(server_pid)
  end

  @doc """
  Gets current state from `ToyRobot.Server.current_state/1`. Then deligates
  actual reporting to `ToyRobot.Logic.report/1` with the current state.
  """
  def report(server_pid) do
    state = current_state(server_pid)
    Logic.report(state)
  end

  @doc """
  Moves the ToyRobot 1 space in the direction it is currently facing.
  **see:** `ToyRobot.Server.do_command/2`
  """
  def move(server_pid) do
    do_command(:move, server_pid)
  end

  @doc """
  Turns the ToyRobot 90 degrees in a **counter clockwise** direction to **Face** in a new direction.
  **see:** `ToyRobot.Server.do_command/2`
  """
  def left(server_pid) do
    do_command(:left, server_pid)
  end

  @doc """
  Turns the ToyRobot 90 degrees in a **clockwise** direction to **Face** in a new direction.
  **see:** `ToyRobot.Server.do_command/2`
  """
  def right(server_pid) do
    do_command(:right, server_pid)
  end

  @doc """
  `handle_call/3` function matching `:get_state` sync call to get the current state.
  """
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @doc """
  `handle_call/3` function matching `:update` sync call to update the current state.
  """
  def handle_call({:update, new_state}, _from, state) do
    {:reply, state, new_state}
  end
end
