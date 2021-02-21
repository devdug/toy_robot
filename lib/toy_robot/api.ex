defmodule ToyRobot.Api do
  @moduledoc """
  The Api module contains the common higher level functions
  that are called from the Command Line `ToyRobot.Cli`
  and File Driven `ToyRobot.FromFile` interfaces.

  This includes functions to:

  - start and stop the `ToyRobot.Server`
  - run commands
  - get server state
  - load a command file
  - and check if command text is vlaid

  Aliased Modules
      ToyRobot.Server
      ToyRobot.Parser
      ToyRobot.Logic


  """

  alias ToyRobot.Server
  alias ToyRobot.Parser
  alias ToyRobot.Logic

  @doc """
  Starts a supervised gen_server to manage state
  for the current position of the toy robot.

  See: `ToyRobot.Server`

  ## Examples

      iex> start_server()
      {:ok, server_pid}

  """
  def start_server() do
    Server.start_link()
  end

  @doc """
  Parses a command via `ToyRobot.Parser.parse_command/1`

  Which converts the command to a map in the form of `%{cmd: cmd, x: x, y: y, face: face}`
  then pipes to process_cmd/1.

  Valid but un-runnable command, such as a "MOVE" that would cause the ToyRobot to fall off the table will be ignored.

  ## Aguments
  cmd:        String
  Server_pid: PID (Process ID)

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

  @doc """
  Processes commands to update servers state.

  Takes a `ToyRobot.Logic` Struct and the `ToyRobot.Server` PID and delegates
  valid commands to command calls in the ToyRobot.Server.

  Invalid commands will print: "invalid commad command_name".

  """
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

  @doc """
  Gets the current state of the ToyRobot.

  Delegates to `ToyRobot.Server.current_state(server_pid)`.
  Returns a ToyRobot.Logic struct in the form of: `%ToyRobot.Logic{face: :n, x: 0, y: 0}`
  """
  def get_server_state(server_pid) do
    Server.current_state(server_pid)
  end

  @doc """
  Stops the server by delegating to `ToyRobot.Server.current_state(server_pid)`.
  """
  def stop_server(server_pid) do
    Process.exit(server_pid, :normal)
  end

  @doc """
  Returns true if `command text (cmd_txt)` is valid, returns false otherwise.
  """
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
