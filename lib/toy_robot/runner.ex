defmodule ToyRobot.Runner do
  use Agent

  alias ToyRobot.Api

  @file_name "empty.txt"

  def run() do

    {:ok, server_pid} = Api.start_server()
    {:ok, agent_pid} = Agent.start_link(fn -> [nil, nil] end, name: __MODULE__)
    loop(server_pid, agent_pid)
  end

  def loop(server_pid, agent_pid) do
    load_file(@file_name, agent_pid)
    cmd = walk_list(agent_pid)
    stop(cmd, server_pid, agent_pid)
    Api.run_cmd(cmd, server_pid)
    loop(server_pid, agent_pid)
  end

  def load_file(name, agent_pid) do
    # store the loaded flag and the current list of cmds
    [list, flag] = get_agent_state(agent_pid)
    case flag == :loaded do
              # skip if alreay loaded
      true -> list
              # actually loads the file
      _    -> list = Api.load_file(name) |> quit_if_empty()
              # save the loaded flag and the list
              set_agent_state(agent_pid, [list, :loaded])
    end
  end

  def quit_if_empty([""] = _list) do
    ["q"]
  end

  def quit_if_empty(list) when is_list(list) do
    list
  end


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

  def set_agent_state(agent_pid, [list, flag]) do
    Agent.update(agent_pid, &(&1 = [list, flag]))
  end

  def get_agent_state(agent_pid) do
    Agent.get(agent_pid, &(&1))
  end

  def stop("q", server_pid, agent_pid) do
    Agent.stop(agent_pid)
    Api.stop_server(server_pid)
    exit(:normal)
  end

  def stop(_,_,_) do
  end

end
