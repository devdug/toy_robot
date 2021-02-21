defmodule ToyRobot.CLI do
  @moduledoc """
  Main entry point which allows application to be run from the command line.

  This module is built using the `escript.build` `mix` command:
  ```elixir
  > mix escript.build
  Generated escript toy_robot with MIX_ENV=dev
  >
  ```
  The application can then be run as a command line application with:
  ```elixir
    > ./toy_robot
  ```

  Or commands can be read from a file named `cmds.txt` in the `/data` directory with:
  ```elixir
    > ./toy_robot -f "/data/cmds.txt"
  ```

  """
  alias ToyRobot.Repl
  alias ToyRobot.FromFile

  @doc """
  Main entry point in the application.

  Parses any arguments from the command line when the application is started.
  Then calls `ToyRobot.CLI.handle_parsed/1`.
  """
  def main(argv) do
    {parsed, _args, _invalid} = OptionParser.parse(argv,
      switches: [from_file: :string],
      aliases: [f: :from_file])

    handle_parsed(parsed)
  end

  @doc """
  Handles parsed command line switches and runs one of two possible application loops.

  If switches is an empty list `[]` i.e no switches were used, in then the **command line** code is run
  by calling `ToyRobot.Repl.run/0`.

  Otherwise if the switches **--from_file** or **-f** are found
  with a **valid file path** then `ToyRobot.FromFile.run/1` is run passing in the
  file path.
  """
  def handle_parsed([from_file: path]) do
    case File.exists?(path) do
      true -> FromFile.run(path)

      _    ->  IO.puts "File not found: #{path}"
    end

  end


  def handle_parsed([]) do
    Repl.run()
  end

  def handle_parsed(_) do
    # show help
    IO.puts "Invalid arguments.."
  end

end
