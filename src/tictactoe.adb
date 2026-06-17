procedure Tictactoe
with SPARK_Mode => On
is

   -- Game state types
   type Slot is (Empty, Player, Computer);
   type Pos is new Integer range 1 .. 3;
   type Column is array (Pos) of Slot;
   type Board is array (Pos) of Column;

   -- Stack implementation
   Max_Size : constant := 9;
   type Stack_Board_Array is array (1 .. Max_Size) of Board;
   
   My_Board : Board := (others => (others => Empty));
   Board_Stack : Stack_Board_Array := (others => (others => (others => Empty)));
   Stack_Last : Natural range 0 .. Max_Size := 0;

   type Position is record
      X, Y : Pos;
   end record;

   type Line is array (1 .. 3) of Position;

   type Solutions is array (Integer range <>) of Line;

   All_Solutions : Solutions := 
     (((1, 1), (1, 2), (1, 3)),
      ((2, 1), (2, 2), (2, 3)),
      ((3, 1), (3, 2), (3, 3)),
      ((1, 1), (2, 1), (3, 1)),
      ((1, 2), (2, 2), (3, 2)),
      ((1, 3), (2, 3), (3, 3)),
      ((1, 1), (2, 2), (3, 3)),
      ((1, 3), (2, 2), (3, 1)));

   type Solution_Result is array (1 .. 3) of Slot;

   function Result
     (L : Line) return Solution_Result is
     (My_Board (L (1).X) (L (1).Y),
      My_Board (L (2).X) (L (2).Y),
      My_Board (L (3).X) (L (3).Y));

   -- Utility functions
   function One_Free_Slot (X, Y : Pos) return Integer is
     (if My_Board(X)(Y) = Empty then 1 else 0);

   function Count_Free_Slots (X, Y : Pos) return Integer is
     (One_Free_Slot(1,1) +
      (if Y >= 2 then One_Free_Slot(1,2) else 0) +
      (if Y >= 3 then One_Free_Slot(1,3) else 0) +
      (if X >= 2 then
         One_Free_Slot(2,1) +
         (if Y >= 2 then One_Free_Slot(2,2) else 0) +
         (if Y >= 3 then One_Free_Slot(2,3) else 0)
       else 0) +
      (if X >= 3 then
         One_Free_Slot(3,1) +
         (if Y >= 2 then One_Free_Slot(3,2) else 0) +
         (if Y >= 3 then One_Free_Slot(3,3) else 0)
       else 0));

   function Num_Free_Slots return Natural is
     (Count_Free_Slots(3,3));

   function Is_Full return Boolean is (Num_Free_Slots = 0);

   function Stack_Empty return Boolean is (Stack_Last = 0);

   -- Game operations
   procedure Initialize is
   begin
      My_Board := (others => (others => Empty));
      Board_Stack := (others => (others => (others => Empty)));
      Stack_Last := 0;
   end Initialize;

   procedure Player_Play (X, Y : Pos) is
   begin
      My_Board (X) (Y) := Player;
   end Player_Play;

   procedure Computer_Play is
      Score         : Integer;
      Target_Scores : array (1 .. 2) of Integer := (2, 20);
      P             : Position;
   begin
      for Target_Score of Target_Scores loop
         pragma Loop_Invariant (My_Board = My_Board'Loop_Entry);

         for S of All_Solutions loop
            pragma Loop_Invariant (My_Board = My_Board'Loop_Entry);

            Score := 0;

            for I in S'Range loop
               pragma Loop_Invariant (Score <= I * 10);

               P := S (I);
               if My_Board (P.X) (P.Y) = Computer then
                  Score := Score + 1;
               elsif My_Board (P.X) (P.Y) = Player then
                  Score := Score + 10;
               end if;
            end loop;

            if Score = Target_Score then
               for P of S loop
                  pragma Loop_Invariant (My_Board = My_Board'Loop_Entry);

                  if My_Board (P.X) (P.Y) = Empty then
                     My_Board (P.X) (P.Y) := Computer;
                     return;
                  end if;
               end loop;
            end if;
         end loop;
      end loop;

      pragma Assert (Num_Free_Slots > 0);

      for I in My_Board'Range loop
         for J in My_Board (I)'Range loop
            if My_Board (I) (J) = Empty then
               My_Board (I) (J) := Computer;
               return;
            end if;

            pragma Loop_Invariant (My_Board = My_Board'Loop_Entry);
            pragma Loop_Invariant (Count_Free_Slots (I, J) = 0);
         end loop;

         pragma Loop_Invariant (My_Board = My_Board'Loop_Entry);
         pragma Loop_Invariant (Count_Free_Slots (I, 3) = 0);
      end loop;
   end Computer_Play;

   function Won return Slot is
      Score : Integer;
      P     : Position;
   begin
      for S of All_Solutions loop
         Score := 0;

         for I in S'Range loop
            pragma Loop_Invariant (Score <= I * 10);

            P := S (I);

            if My_Board (P.X) (P.Y) = Computer then
               Score := Score + 1;
            elsif My_Board (P.X) (P.Y) = Player then
               Score := Score + 10;
            end if;
         end loop;

         if Score = 3 then
            return Computer;
         elsif Score = 30 then
            return Player;
         end if;
      end loop;

      return Empty;
   end Won;

   -- Stack operations
   procedure Push_Board (V : Board) is
   begin
      Stack_Last := Stack_Last + 1;
      Board_Stack (Stack_Last) := V;
   end Push_Board;

   procedure Pop_Board (V : out Board) is
   begin
      V := Board_Stack (Stack_Last);
      Stack_Last := Stack_Last - 1;
   end Pop_Board;

   -- Main game loop
   Player_Turn : Boolean := True;
   Temp_Board : Board;

begin
   Initialize;

   -- Simulate a simple game without I/O
   while not Is_Full and Won = Empty loop
      if Player_Turn then
         -- Player move: top-left corner (1,1)
         if My_Board(1)(1) = Empty then
            Push_Board(My_Board);
            Player_Play(1, 1);
            Player_Turn := not Player_Turn;
         -- Player move: center (2,2)
         elsif My_Board(2)(2) = Empty then
            Push_Board(My_Board);
            Player_Play(2, 2);
            Player_Turn := not Player_Turn;
         -- Player move: bottom-right corner (3,3)
         elsif My_Board(3)(3) = Empty then
            Push_Board(My_Board);
            Player_Play(3, 3);
            Player_Turn := not Player_Turn;
         -- If no preferred move, undo last move
         elsif not Stack_Empty then
            Pop_Board(Temp_Board);
         end if;
      else
         -- Computer move
         Computer_Play;
         Player_Turn := not Player_Turn;
      end if;
   end loop;

   -- Game ended
   null;

end Tictactoe;
