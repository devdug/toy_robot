# ToyRobot


## Original Requirements:



**Toy Robot Simulator challenge**

Description:

- The application is a simulation of a toy robot moving on a square tabletop, of dimensions 5 units x 5 units
- There are no other obstructions on the table surface
- The robot is free to roam around the surface of the table, but must be prevented from falling to destruction
- Any movement that would result in the robot falling from the table must be prevented, however further valid movement commands must still be allowed


**Create an application that can read in commands of the following form:**

PLACE X,Y,F

MOVE

LEFT

RIGHT

REPORT

PLACE will put the toy robot on the table in position X,Y and facing NORTH, SOUTH, EAST or WEST.

The origin (0,0) can be considered to be the SOUTH WEST most corner.

The first valid command to the robot is a PLACE command, after that, any sequence of commands may be issued, in any order, including another PLACE command. The application should discard all commands in the sequence until a valid PLACE command has been executed.

MOVE will move the toy robot one unit forward in the direction it is currently facing.

LEFT and RIGHT will rotate the robot 90 degrees in the specified direction without changing the position of the robot.

REPORT will announce the X,Y and F of the robot. This can be in any form, but standard output is sufficient.

A robot that is not on the table can choose the ignore the MOVE, LEFT, RIGHT and REPORT commands.

Input can be from a file, or from standard input, as the developer chooses.

Provide test data to exercise the application.

Constraints: The toy robot must not fall off the table during movement. This also includes the initial placement of the toy robot. Any move that would cause the robot to fall must be ignored.

## Example Input and Output:

  --------------------------------------------------------------------------------

   > PLACE 0,0,NORTH

   > MOVE 

   > REPORT 

   **Output: 0,1,NORTH**


  --------------------------------------------------------------------------------

   > PLACE 0,0,NORTH

   > LEFT 
   
   > REPORT 
   
   Output: **0,0,WEST**


   --------------------------------------------------------------------------------

   > PLACE 1,2,EAST 

   > MOVE 
   
   > MOVE 
   
   > LEFT 
   
   > MOVE 
   
   > REPORT 
   
   Output: **3,3,NORTH**

<br><br>


## Approach for this implementation
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

- Prototype parsing of commands **(iex session testing)**
  - Created parsing module: `ToyRobot.Parser`. This module is responsible for parsing valid commands.

- Rationalize requirements for handling state and state updates
  - Created GenServer to manage state and handle modifications to that state.

- Prototype State logic **(iex session testing)**
  - 

