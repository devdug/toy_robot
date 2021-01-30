defmodule ToyRobot.Runner do
  use Agent

  alias ToyRobot.Server
  alias ToyRobot.Parser
  alias ToyRobot.Logic

  @file_name "cmds.txt"

  def run() do
    {:ok, agent_pid} = Agent.start_link(fn -> [nil, nil] end, name: __MODULE__)

    {:ok, server_pid} = Server.start_link()

    Process.sleep(500)
    loop(server_pid, agent_pid)
  end

  def loop(server_pid, agent_pid) do
    #  single load
    load_file(@file_name, agent_pid)

    # loop through list
      cmd = walk_list(agent_pid)
      stop(cmd, server_pid, agent_pid)

      if is_binary(cmd) do
        Parser.parse_command(cmd)
        |> process_cmd(server_pid)
      end

    loop(server_pid, agent_pid)
  end

  def stop("q", server_pid, agent_pid) do
    Agent.stop(agent_pid)
    Process.exit(server_pid, :normal)
    exit(:normal)
  end

  def stop(_,_,_) do
  end

  def walk_list(agent_pid) do
    [cmds, flag] = get_agent_state(agent_pid)

    cmd =
      if flag == :loaded and is_list(cmds) do
        {cmd, cmds} = List.pop_at(cmds, 0)
        set_agent_state(agent_pid, [cmds, flag])
        cmd
      end

    cmd
  end

  def process_cmd(map, server_pid) do
    IO.puts("processing cmd: #{inspect(map)}")

    if (map.cmd in Parser.cmds()) do
      cond do
        map.cmd == "MOVE"   -> Server.move(server_pid)
        map.cmd == "LEFT"   -> Server.left(server_pid)
        map.cmd == "RIGHT"  -> Server.right(server_pid)
        map.cmd == "PLACE"  -> Server.place(server_pid, [map.x, map.y, map.face])
        map.cmd == "REPORT" -> cur_state = get_server_state(server_pid)
                               Logic.report(cur_state)

        true -> IO.puts("invalid commad: #{map.cmd}")
      end
    end
  end

  def get_server_state(server_pid) do
    Server.current_state(server_pid)
  end

  def load_file(name, agent_pid) do
    [list, flag] = get_agent_state(agent_pid)
    case flag == :loaded do
      true -> list
      _    -> list = Logic.load_file(name)
              set_agent_state(agent_pid, [list, :loaded])
    end
  end

  def set_agent_state(agent_pid, [list, flag]) do
    Agent.update(agent_pid, &(&1 = [list, flag]))
  end

  def get_agent_state(agent_pid) do
    Agent.get(agent_pid, &(&1))
  end

  def get_state(server_pid) do
    Server.current_state(server_pid)
  end

end
