defmodule ToyRobot.Logic do
@moduledoc """
Applies the rules as to what is a valid command and updates the
`%ToyRobot.Logic{}` struct if a command is valid.

## Original Requirements:

**Toy Robot Simulator challenge**

Description:

- The application is a simulation of a toy robot moving on a square tabletop, of dimensions 5 units x 5 units
- There are no other obstructions on the table surface
- The robot is free to roam around the surface of the table, but must be prevented from falling to destruction
- Any movement that would result in the robot falling from the table must be prevented, however further valid movement commands must still be allowed


**Create an application that can read in commands of the following form:**

```elixir
PLACE X,Y,F

MOVE

LEFT

RIGHT

REPORT
```

PLACE will put the toy robot on the table in position X,Y and facing NORTH, SOUTH, EAST or WEST.

The origin (0,0) can be considered to be the SOUTH WEST most corner.

The first valid command to the robot is a PLACE command, after that, any sequence of commands may be issued, in any order, including another PLACE command. The application should discard all commands in the sequence until a valid PLACE command has been executed.

MOVE will move the toy robot one unit forward in the direction it is currently facing.

LEFT and RIGHT will rotate the robot 90 degrees in the specified direction without changing the position of the robot.

REPORT will announce the X,Y and F of the robot. This can be in any form, but standard output is sufficient.

A robot that is not on the table can choose the ignore the MOVE, LEFT, RIGHT and REPORT commands.

Input can be from a file, or from standard input, as the developer chooses.

Provide test data to exercise the application.

Constraints: The toy robot must not fall off the table during movement. This also includes the initial placement of the toy robot. Any move that would cause the robot to fall must be ignored. Also the PLACE command must contain a single space only.

## Example Input and Output:

This first example is of a command without a prior PLACE command.
```elixir
    > REPORT
    > Robot is not placed
```
  --------------------------------------------------------------------------------
```elixir
    > PLACE 0,0,NORTH
    > MOVE
    > REPORT
    > Robot is at 0, 1 and facing NORTH
```

  --------------------------------------------------------------------------------
```elixir
    > PLACE 0,0,NORTH
    > LEFT
    > REPORT
    > Robot is at 0, 0 and facing WEST
```

   --------------------------------------------------------------------------------
```elixir
    > PLACE 1,2,EAST
    > MOVE
    > MOVE
    > LEFT
    > MOVE
    > REPORT
    > Output: Robot is at 3, 3 and facing NORTH
```
"""

  @type data() :: %ToyRobot.Logic{}

  # Use keyword lists to determine direction changes
  # This eliminates testing the directions such as: if face == "EAST" do "SOUTH" for a RIGHT command.
  # Instead @right[:e] does the same thing as it returns :s.
  @right [n: :e, e: :s, s: :w, w: :n]
  @left [n: :w, w: :s, s: :e, e: :n]
  # @info converts atoms into uppercase strings for the REPORT command.
  @info [n: "NORTH", e: "EAST", s: "SOUTH", w: "WEST"]
  # @face contains valid facing directions
  @face [:n, :e, :s, :w]
  # 5 x 5 table
  @table_size 5

  # ToyRobot.Logic struct
  defstruct x: 0, y: 0, face: nil

  @doc false
  # A nil :face value in the struct indicates the robot is not placed.
  def new(), do: %ToyRobot.Logic{x: 0, y: 0, face: nil}

  @doc """
  Places the Toy Robot onto the table.

  A `PLACE` command acts as a teleporter
  to move the toy robot any where on the table and can be used at any time.

  The `PLACE` command must not have more than one space in the entire command.

  Example Invalid `PLACE` commands:
  ```elixir
  > PLACE 2, 3,NORTH

  > PLACE  2,3,NORTH

  > PLACE 2,3, NORTH
  ```
  A valid `PLACE` command
  ```elixir
  > PLACE 2,3,NORTH
  ```
  """
  def place(x, y, face) do
    x = x |> String.to_integer()
    y = y |> String.to_integer()
    face = word2atom(face)
    %ToyRobot.Logic{x: x, y: y, face: face}
  end

  @doc """
  Reports the Toy Robot's current position on the table.

  The `data` argumnet is a `%ToyRobot.Logic{x: x, y: y, face: face}` struct.
  Examples:
  When the robot has not been **PLACED** yet:
  ```elixir
  > REPORT
  > Robot is not placed
  ```
  When the robot has been **PLACED** at 2,3,WEST
  ```elixir
  > REPORT
  > Robot is at 2, 3 and facing WEST
  ```
  """
  def report(data) do
    case valid?(data) do
      true ->
        IO.puts("Robot is at (#{data.x}, #{data.y}) and facing #{@info[data.face]}")
      _ ->
        IO.puts("Robot is not placed")
    end
  end

  @doc """
  Moves the Toy Robot 1 space in the direction it is currently facing.

  The `data` argument is a `%ToyRobot.Logic{}` struct.
  The move is ignored (the data is unchanged) if the move would cause the toy robot to fall off the table.
  Otherwise the make_move
  """
  def move(data) when is_struct(data) do
    case can_move?(data) do
      true -> make_move(data)
      _ -> data
    end
  end

  @doc """
  Rotates the Toy Robot 90 degrees to the right at the robot's current position on the table.

  Example
  ```elixir
  > PLACE 2,2,NORTH
  > REPORT
  > Robot is at 2, 2 and facing NORTH
  > RIGHT
  > REPORT
  > Robot is at 2, 2 and facing EAST
  ```
  """
  def right(data) when is_struct(data) do
    case valid?(data) do
      true -> %{data | face: @right[data.face]}
      _ -> data
    end
  end

  @doc """
  Rotates the Toy Robot 90 degrees to the left at the robot's current position on the table.

  Example
  ```elixir
  > PLACE 2,2,NORTH
  > REPORT
  > Robot is at 2, 2 and facing NORTH
  > LEFT
  > REPORT
  > Robot is at 2, 2 and facing WEST
  ```
  """
  def left(data) when is_struct(data) do
    case valid?(data) do
      true -> %{data | face: @left[data.face]}
      _ -> data
    end
  end

  @doc false
  # Checks that the `x`, `y`, and `face` values are valid in the `%ToyRobot.Logic{}` struct passed as the `data` argument.
  # Examples
  # ```elixir
  # data = ToyRobot.Logic.new()
  # ```
  # Then data would be:
  # ```elixir
  # > data
  # > %ToyRobot.Logic{x: 0, y: 0, face: nil}
  # ```
  # `face: nil` is invalid and is used to indicate the robot has not been placed yet.
  # ```elixir
  # > data = ToyRobot.Logic.new()
  # > ToyRobot.Logic.valid?(data)
  # > false
  # ```
  # Any x or y values that are `< 0 or > (@table_size - 1)` are also invalid and would result in a false value returned.
  #
  def valid?(data) when is_struct(data) do
    data.x >= 0 &&
    data.x <= (@table_size - 1) &&
    data.y >= 0 &&
    data.y <= (@table_size - 1) &&
    data.face in @face
  end

  @doc false
  def can_move?(data) do
    (data.face == :n && data.y < (@table_size - 1)) ||
    (data.face == :e && data.x < (@table_size - 1)) ||
    (data.face == :s && data.y > 0) ||
    (data.face == :w && data.x > 0)
  end

  @doc false
  def make_move(data) do
    case valid?(data) do
      true -> move_facing(data)
      _ -> data
    end
  end

  @doc false
  # Adjusts x,y values for a move based on the facing direction
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

  @doc false
  def word2atom(face) when is_atom(face) and face in @face, do: face

  @doc false
  def word2atom(txt) when is_binary(txt) do
    txt
    |> String.downcase()
    |> String.first()
    |> String.to_atom()
  end

end
