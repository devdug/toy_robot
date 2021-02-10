defmodule ToyRobot.Api do
  @moduledoc """
  ## `ToyRobot.Api`.

  The Api module contains the higher level functions
  that are called from the Command Line `ToyRobot.Cli`
  and File Driven `ToyRobot.FromFile` interfaces.

  ### Aliased Modules
  `ToyRobot.Server`
  `ToyRobot.Parser`
  `ToyRobot.Logic`
  """

  alias ToyRobot.Server
  alias ToyRobot.Parser
  alias ToyRobot.Logic

  @doc """
  ## start_server/0.
  Starts a supervised gen_server to manage state
  for the current position of the toy robot.

  ## Examples

      iex> start_server()
      {:ok, server_pid}

  """
  def start_server do
    {:ok, server_pid} = Server.start_link()
    {:ok, server_pid}
  end

  @doc """
  ## run_cmd/2.
  Parses a command via `ToyRobot.Parser/1` which converts
  the command to a map in the form of `%{cmd: cmd, x: x, y: y, face: face}`
  then calls the matching command in `ToyRobot.Server` to update the
  current state of the toy robot.

  Invalid commands will be ignored.

  ## Examples

      iex> ToyRobot.Api.run_cmd("MOVE", server_pid)
      :ok

      iex> ToyRobot.Api.run_cmd(10, server_pid)
      nil

  """
  def run_cmd(cmd, server_pid) do
    if is_binary(cmd) do
      Parser.parse_command(cmd)
      |> process_cmd(server_pid)
    end
  end

  def process_cmd(map, server_pid) do
    # IO.puts("processing cmd: #{inspect(map)}")

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

  def stop_server(server_pid) do
    Process.exit(server_pid, :normal)
  end

  def load_file(file_name) do
    Logic.load_file(file_name)
  end

  def valid_cmd?(cmd_txt) do
    if cmd_txt != "" do
      [cmd, _args] =
        Parser.split_cmd_txt(cmd_txt)
        |> Parser.validate_cmd()
      !is_nil(cmd)
    else
      false
    end
  end

end
