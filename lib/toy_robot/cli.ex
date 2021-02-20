defmodule ToyRobot.CLI do
  @moduledoc """
  main(argv) Main entry point which allows application to be run from the command line
  """
  alias ToyRobot.Repl
  alias ToyRobot.FromFile

  def main(argv) do
    {parsed, _args, _invalid} = OptionParser.parse(argv,
      switches: [interactive: nil, from_file: :string],
      aliases: [i: :interactive, f: :from_file])

    handle_parsed(parsed)
  end

  def handle_parsed([from_file: path]) do
    case File.exists?(path) do
      true -> FromFile.run(path)

      _    ->  IO.puts "File not found: #{path}"
    end

  end

  def handle_parsed([interactive: true]) do
    Repl.run()
  end

  def handle_parsed(_) do
    # show help
    IO.puts "Invalid arguments.."
  end

end
