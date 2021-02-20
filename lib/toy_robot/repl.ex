defmodule ToyRobot.Repl do
  @moduledoc """
  REPL loop for command line interface.
  """
  alias ToyRobot.Api

  @doc """
  Starts the Api server and on success calls the `ToyRobot.Repl.loop/1` function.
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
