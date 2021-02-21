defmodule ToyRobot.Loader do
@moduledoc """
Specific file utilities for ToyRobot.
"""

  @doc """
  Loads the file from the **file name** passed in.

  Returns a list of strings representing commands to run.
  """
  def load_file(name) do
    name
    |> find_file()
    |> file_found()
  end

  @doc false
  def find_file(name) do
    case File.exists?(name) do
      true  -> {:ok, name}
      false -> {:error, "File not found: #{name}"}
    end
  end

  @doc false
  def file_found({:ok, name}) do
    name
    |> File.read()
    |> handle_file()
  end

  @doc false
  def file_found({:error, reason}) do
    IO.puts reason
    handle_file({:error, reason})
  end

  @doc false
  def handle_file({:ok, contents}) when is_binary(contents) do
    contents |> String.split("\n")
  end

  @doc false
  def handle_file({:error, _reason}) do
    [""]
  end

end
