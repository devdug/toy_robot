defmodule ToyRobot.Cli do
  alias ToyRobot.Api

  def run() do
    IO.inspect System.argv
    # {:ok, server_pid} = Api.start_server()
    # loop(server_pid)
  end

  def loop(server_pid) do
    cmd_txt = IO.gets("command > ") |> String.trim()

    if cmd_txt == "q" do
      Api.stop_server(server_pid)
      exit(:normal)
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
