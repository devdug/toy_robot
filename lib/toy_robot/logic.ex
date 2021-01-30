defmodule ToyRobot.Logic do

  alias ToyRobot.Loader

  @right [n: :e, e: :s, s: :w, w: :n]
  @left [n: :w, w: :s, s: :e, e: :n]
  @info [n: "NORTH", e: "EAST", s: "SOUTH", w: "WEST"]

  @face [:n, :e, :s, :w]

  defstruct x: 0, y: 0, face: nil

  def new(), do: %ToyRobot.Logic{x: 0, y: 0, face: nil}

  def load_file(name) do
    Loader.load_file(name)
  end

  def place(x, y, face) do
    x = x |> String.to_integer()
    y = y |> String.to_integer()
    face = word2atom(face)
    %ToyRobot.Logic{x: x, y: y, face: face}
  end

  def report(data) do
    case valid?(data) do
      true ->
        IO.puts("Robot is at (#{data.x}, #{data.y}) and facing #{@info[data.face]}")
      _ ->
        IO.puts("Robot is not placed")
    end
  end

  def move(data) when is_struct(data) do
    case can_move?(data) do
      true -> make_move(data)
      _ -> data
    end
  end

  def right(data) when is_struct(data) do
    case valid?(data) do
      true -> %{data | face: @right[data.face]}
      _ -> data
    end
  end

  def left(data) when is_struct(data) do
    case valid?(data) do
      true -> %{data | face: @left[data.face]}
      _ -> data
    end
  end

  def valid?(data) when is_struct(data) do
    data.x >= 0 &&
    data.x <= 4 &&
    data.y >= 0 &&
    data.y <= 4 &&
    data.face in @face
  end

  def can_move?(data) do
    (data.face == :n && data.y < 4) ||
    (data.face == :e && data.x < 4) ||
    (data.face == :s && data.y > 0) ||
    (data.face == :w && data.x > 0)
  end

  def make_move(data) do
    case valid?(data) do
      true -> move_facing(data)
      _ -> data
    end
  end

  def move_facing(data) do
    cond do
      data.face == :n ->
        %{data | y: data.y + 1}
      data.face == :s ->
        %{data | y: data.y - 1}
      data.face == :e ->
        %{data | x: data.x + 1}
      data.face == :w ->
        %{data | x: data.x - 1}
    end
  end

  def word2atom(face) when is_atom(face) and face in @face, do: face

  def word2atom(txt) when is_binary(txt) do
    txt
    |> String.downcase()
    |> String.first()
    |> String.to_atom()
  end

end
