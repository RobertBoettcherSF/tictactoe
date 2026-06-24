-- Package specification for Tic-Tac-Toe game types

package Tictactoe_Types is
   -- Types and constants used by the game
   type Slot is (Empty, Player, Computer);
   type Pos is new Integer range 1 .. 3;
   type Column is array (Pos) of Slot;
   type Board is array (Pos) of Column;

   Max_Size : constant := 9;
end Tictactoe_Types;
