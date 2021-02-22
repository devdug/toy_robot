# Approach
How I approached this implementation of the ToyRobot challenge.
--------------------------------------------------------------------------------

This implementation will allow for two different user interfaces so there needs to be a higher level context to drive each interface. The interfaces implemented are a `command_line` interface and a `read_from_command_file` interface.

```elixir
Note: Often logic can be represented in data elements that inherently provide that logic.

As an example the different directions a robot can be facing are ["NORTH", "EAST", "SOUTH", "WEST"]
Since there are two rotaion commands `LEFT` and `RIGHT` the results of any rotation transformation can be "looked-up" in module attributes:

@right [n: :e, e: :s, s: :w, w: :n]
@left [n: :w, w: :s, s: :e, e: :n]

This eliminates a bunch of code needed to test and resolve direction changes, and provides extensibility just by adding to the attribute list.

```
There needs to be a way to handle state and state transformations so a `GenServer` is a good start. The `Server` module will transform the state by using modules that parse commands and apply logic for the two different interfaces.

There are a finite set of commands with clear formats so a `command parser` is another context candidate. This will provide data elements for valid commands and valid drections of which way the toy_robot can face. The `Parser` module will conatin this context.

The `logic` that controls transformations of state between commands is another context candidate. The logic can be broken down to playing_surface boundaries which equate to `current_row_and_column` being `>= 0` and `<= table size - 1`, and determining direction and movement. The `Logic` module will contain a `Struct` for `position and direction facing` and use data elements to **look-up** transitions for direction.

## Methodology
The methodology for this project was to start with the reasonable progression of how data will move through the system, starting with the most clearly defined requirement: `Commands`.

The general decomposition of requirements above indicates that a first **high-level** pipe-line could be:  

```elixir
  parse_command(cmd)
  |> process_cmd(server_pid)
```
Build the parse_command function first.  
- First need to split the `command_text` into its component parts.
- Then validate that the `command` is in our list of valid commands: ["PLACE", "MOVE", "LEFT", "RIGHT", "REPORT"] 
- Then transform the command into a common format that can be passed between modules. A map in this case.

So our parse_command eventually looked like the following:
```elixir
def parse_command(cmd_txt) when is_binary(cmd_txt) do
  cmd_txt
  |> split_cmd_txt()
  |> validate_cmd()
  |> to_map()
end
```

Lets test each of the functions in the parse_command/1 function.

```elixir
def split_cmd_txt(cmd_txt) when not is_list(cmd_txt) and is_binary(cmd_txt) do
    parts = cmd_txt |> String.split()
    cmd  = parts |> hd()
    args = parts |> List.last() |> String.split(",")
    [cmd, args]
end
```
It is easy to test in `iex` and see how things need to be parsed and what works best for all happy path scenarios.  

Only the `PLACE` command has arguments so lets test that first.
```elixir
iex > cmd_txt = "PLACE 0,0,NORTH"
"PLACE 0,0,NORTH"

iex > parts = cmd_txt |> String.split()
["PLACE", "0,0,NORTH"]

iex > cmd = parts |> hd()
"PLACE"

iex > args = parts |> List.last() |> String.split(",")
["0", "0", "NORTH"]

iex > [cmd, args]
["PLACE", ["0", "0", "NORTH"]]

iex > cmd
"PLACE"

iex > args
["0", "0", "NORTH"]
```

Now lets test the same code with a command that has no arguments
```elixir
iex > cmd_txt = "MOVE"
"MOVE"

iex > parts = cmd_txt |> String.split()
["MOVE"]

iex > cmd = parts |> hd()
"MOVE"

iex > args = parts |> List.last() |> String.split(",")
["MOVE"]

iex > [cmd, args]
["MOVE", ["MOVE"]]
```

```elixir
    iex > Parser.parse_command("MOVE")
    %{cmd: "MOVE", face: nil, x: nil, y: nil}
    iex >
```

**iex Driven Development**

Requires that all functions in every module can be individually tested and that there are clear boundaries between Contexts. This does not prevent easy aggreagtion of functionality between modules.

Testing in `iex` allows a very quick code-test-fix cycle in small light weight increments.

It allows for a brain-dump of functionality and then through code reviews decide how functionality should be consolodated, refactored, or deleted.


----------------
Originial idead by Jon Eaves: [https://joneaves.wordpress.com/2014/07/21/toy-robot-coding-test/](https://joneaves.wordpress.com/2014/07/21/toy-robot-coding-test/)