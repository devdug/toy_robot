defmodule ToyRobot.FromFile do
  @moduledoc """
  Interface for reading commands from a file.


  """
  use Agent

  alias ToyRobot.Api
  alias ToyRobot.Loader

  @doc """
  Starts the Api server and on success calls the `ToyRobot.FromFile.loop/2` function to run the interface.

  Also starts an `Agent` to maintain state of the file as it is processed on command at a time.
  """
  def run(path) do
    {:ok, server_pid} = Api.start_server()
    {:ok, agent_pid} = Agent.start_link(fn -> [nil, nil] end, name: __MODULE__)

    load_file(path, agent_pid)

    loop(server_pid, agent_pid)
  end

  @doc """
  Main run loop for the interface.

  Uses an Agent to mainatain state of the command list.

  """
  def loop(server_pid, agent_pid) do
    walk_list(agent_pid)
    |> stop(server_pid, agent_pid)
    |> Api.run_cmd(server_pid)

    loop(server_pid, agent_pid)
  end

  @doc false
  # Loads the updated in-memory state of the file from the Agent
  # Provides a one-shot load, so it can be used in a loop
  def load_file(name, agent_pid) do
    # store the loaded flag and the current list of cmds
    [list, flag] = get_agent_state(agent_pid)
    case flag == :loaded do
              # skip if alreay loaded
      true -> list
              # actually loads the file from path
      _    -> list = Loader.load_file(name) |> quit_if_empty()
              # save the loaded flag and the list
              set_agent_state(agent_pid, [list, :loaded])
    end
  end

  @doc false
  # Delegates to the `ToyRobot.Loader.load_file` to load the commands.
  def load_file(name) do
    Loader.load_file(name)
  end

  @doc false
  # returns a "q" i.e quit command if the command is empty.
  def quit_if_empty([""] = _list) do
    ["q"]
  end

  @doc false
  # Passes through the list if not caught by above version.
  def quit_if_empty(list) when is_list(list) do
    list
  end

  @doc """
  Walk the list of commands and **pops** each command off the list and returns it.

  Updates the Agent state as each command is removed to the list.
  """
  def walk_list(agent_pid) do
    [cmds, flag] = get_agent_state(agent_pid)
    cmd =
      if flag == :loaded and is_list(cmds) do
        {cmd, cmds} = List.pop_at(cmds, 0)
        set_agent_state(agent_pid, [cmds, flag])
        cmd
      end
    IO.puts "processing #{cmd}"
    cmd
  end

  @doc false
  def set_agent_state(agent_pid, [list, flag]) do
    Agent.update(agent_pid, &(&1 = [list, flag]))
  end

  @doc false
  def get_agent_state(agent_pid) do
    Agent.get(agent_pid, &(&1))
  end

  @doc false
  def stop("q", server_pid, agent_pid) do
    Agent.stop(agent_pid)
    Api.stop_server(server_pid)
    exit(:normal)
  end

  @doc false
  # Pass through when command is not "q". Allow for piping in main loop.
  def stop(cmd,_,_) do
    cmd
  end

end
