defmodule ToyRobot.Loader do

  def load_file(name) do
    Path.expand("../../data",__DIR__)
    |> Path.join(name)
    |> File.read()
    |> handle_file()
  end

  def handle_file({:ok, contents}) when is_binary(contents) do
    contents |> String.split("\n")
  end

  def handle_file({:error, _reason}) do
    [""]
  end

end

# def func(%{x: x, y: y} = map)
