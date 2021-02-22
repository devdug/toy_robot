# ToyRobot

## Toy Robot Simulator challenge

**Original Requirements**

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

## PLACE

PLACE will put the toy robot on the table in position X,Y and facing NORTH, SOUTH, EAST or WEST.

The origin (0,0) can be considered to be the SOUTH WEST most corner.

The first valid command to the robot is a PLACE command, after that, any sequence of commands may be issued, in any order, including another PLACE command. The application should discard all commands in the sequence until a valid PLACE command has been executed.

## MOVE

MOVE will move the toy robot one unit forward in the direction it is currently facing.

LEFT and RIGHT will rotate the robot 90 degrees in the specified direction without changing the position of the robot.

## REPORT

REPORT will announce the X,Y and F of the robot. This can be in any form, but standard output is sufficient.

A robot that is not on the table can choose the ignore the MOVE, LEFT, RIGHT and REPORT commands.

## Intefaces

Input can be from a file, or from standard input, as the developer chooses.

Provide test data to exercise the application.

Constraints: The toy robot must not fall off the table during movement. This also includes the initial placement of the toy robot. Any move that would cause the robot to fall must be ignored. Also the PLACE command must contain a single space only.

## Example Input and Output (Command Line):

Run the following to start the command line interface:
    > ./toy_robot

This first example is of a command without a prior PLACE command.
```elixir
> REPORT
Output: Robot is not placed
>
```
  --------------------------------------------------------------------------------
PLACE 0,0,NORTH will put the robot at the SOUTH WEST corner (bottom left) of the table
at `x = 0, y = 0`.

The MOVE command will move the robot forward one space in the direction is is facing.   
Which when facing NORTH would be **up** or facing in the positive `y` direction.
```elixir
> PLACE 0,0,NORTH
> MOVE
> REPORT
Output: Robot is at 0, 1 and facing NORTH
>
```
So facing as listed below folled with a `MOVE` command changes the coordinates thus:

    - NORTH   `Y + 1`
    - SOUTH   `Y - 1` 
    - EAST    `X + 1`
    - WEST    `X - 1`
  --------------------------------------------------------------------------------
LEFT rotates the robot 90 degrees to the left. So a LEFT form NORTH faces the robot to the WEST:
```elixir
> PLACE 0,0,NORTH
> LEFT
> REPORT
Output: Robot is at 0, 0 and facing WEST
>
```

   --------------------------------------------------------------------------------
All commands can be repeated as desired:
```elixir
> PLACE 1,2,EAST
> MOVE
> MOVE
> REPORT
Output: Robot is at 3, 2 and facing EAST
> LEFT
> REPORT
Output: Robot is at 3, 2 and facing NORTH
> MOVE
> REPORT
Output: Robot is at 3, 3 and facing NORTH
>
```
----------------
Originial idea by Jon Eaves: [https://joneaves.wordpress.com/2014/07/21/toy-robot-coding-test/](https://joneaves.wordpress.com/2014/07/21/toy-robot-coding-test/)