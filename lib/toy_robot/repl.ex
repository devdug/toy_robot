defmodule ToyRobot.Repl do
  @moduledoc """
  REPL loop for command line interface.
  """
  alias ToyRobot.Api

  @doc """
  Starts the Api server and on success calls the `ToyRobot.Repl.loop/1` function to run the repl.
  """
  def run() do
    # Api.start_server() returns {:ok, server_pid} or {:error, reason} tuples.
    # flag will be :ok or :error
    # value will be server_pid or the error reason.
    {flag, value} = Api.start_server()

    case {flag, value} do
      {:ok, value} ->
        loop(value)

      {:error, value} ->
        IO.puts "Server failed to start. Reason: #{value}"
    end

  end

  @doc """
  Main repl loop

  Gets command text from the command line.
  if command is "q" then the loop is stoped and `ToyRobot.Api.stop_server/1`
  is called to shutdown the `ToyRobot.Server`.

  Otherwise the command is validated and if valid the
  `ToyRobot.Api.run_cmd/2` is called.

  If not valid invalid command: `the command`
  is printed to the command line.

  Example:
  ```elixir
  $ > ./toy_robot -i

  command >
  command > PLACE 1,1,NORTH
  command > REPORT
  Robot is at (1, 1) and facing NORTH
  command > bogus
  invalid command: bogus
  command > REPORT
  Robot is at (1, 1) and facing NORTH
  command > MOVE
  command > MOVE
  command > REPORT
  Robot is at (1, 3) and facing NORTH
  command > q

  $ >
  ```
  """
  def loop(server_pid) do
    cmd_txt = IO.gets("command > ") |> String.trim()

    if cmd_txt == "q" do
      Api.stop_server(server_pid)
      exit(:shutdown)
    end

    if Api.valid_cmd?(cmd_txt) do
      # run the command
      Api.run_cmd(cmd_txt, server_pid)
    else
      IO.puts "invalid command: #{cmd_txt}"
    end

    loop(server_pid)
  end

end
