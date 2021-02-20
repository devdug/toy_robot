defmodule ToyRobot.Loader do

  def load_file(name) do
    name
    |> find_file()
    |> file_found()
  end

  def find_file(name) do
    case File.exists?(name) do
      true  -> {:ok, name}
      false -> {:error, "File not found: #{name}"}
    end
  end

  def file_found({:ok, name}) do
    name
    |> File.read()
    |> handle_file()
  end

  def file_found({:error, reason}) do
    IO.puts reason
    handle_file({:error, reason})
  end

  def handle_file({:ok, contents}) when is_binary(contents) do
    contents |> String.split("\n")
  end

  def handle_file({:error, _reason}) do
    [""]
  end

end
