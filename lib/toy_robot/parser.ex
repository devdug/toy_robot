defmodule ToyRobot.Parser do

  @cmds ["PLACE", "MOVE", "LEFT", "RIGHT", "REPORT"]
  @dirs ["NORTH", "EAST", "SOUTH", "WEST"]
  @arg_cmds ["PLACE"]

  def cmds() do
    @cmds
  end

  def parse_command(cmd_txt) when is_binary(cmd_txt) do
      cmd_txt
      |> split_cmd_txt()
      |> validate_cmd()
      |> to_map()
  end

  def to_map([_cmd, args]) when is_nil(args) do
    %{cmd: nil, x: nil, y: nil, face: nil}
  end

  def to_map([cmd, args]) when not is_nil(args) do
    [cmd, [x, y, face]] = [cmd, args]
    %{cmd: cmd, x: x, y: y, face: face}
  end

  def split_cmd_txt(cmd_txt) when is_binary(cmd_txt) do
    parts = cmd_txt |> String.split()
    cmd  = parts |> hd()
    args = parts |> List.last() |> String.split(",")
    [cmd, args]
  end

  def validate_cmd([cmd, args]) when cmd in @arg_cmds and is_list(args) do
    [cmd, args] = validate_args(cmd, args)

    if is_nil(args) do
        [nil, [nil, nil, nil]]
    else
      [cmd, [_x, _y, _face] = args]
    end
  end

  def validate_cmd([cmd, _args]) when cmd in @cmds and cmd not in @arg_cmds do
    [cmd, [nil, nil, nil]]
  end

  def validate_args(cmd, args) when cmd in @arg_cmds and is_list(args) do
    case valid_arg_values(args) do
      true ->
        [_cmd, [_x, _y, _face]] = [cmd, args]
    false ->
      [nil, nil]
    end
  end

  def valid_arg_values([x, y, face]) do
    x = String.to_integer(x)
    y = String.to_integer(y)

    x >= 0 and y >= 0 and
    x <= 4 and y <= 4 and
    face in @dirs
  end

  def valid_arg_values(_) do
    false
  end
end
