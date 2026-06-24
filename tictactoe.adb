with Ada.Text_IO; use Ada.Text_IO;

procedure Tictactoe is

   -- Game types
   type Slot is (Empty, Player, Computer);
   type Pos is new Integer range 1 .. 3;
   type Column is array (Pos) of Slot;
   type Board is array (Pos) of Column;

   Max_Size : constant := 9;

   My_Board : Board := (others => (others => Empty));

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

   -- Stack for undo functionality
   Tab : array (1 .. Max_Size) of Board := (others => (others => (others => Empty)));
   Last : Natural range 0 .. Max_Size := 0;

   function Full return Boolean is (Last >= Max_Size);
   function Empty return Boolean is (Last < 1);
   function Size return Integer is (Last);

   procedure Clear is
   begin
      Last := Tab'First - 1;
   end Clear;

   procedure Push (V : Board) is
   begin
      Last := Last + 1;
      Tab (Last) := V;
   end Push;

   procedure Pop (V : out Board) is
   begin
      V := Tab (Last);
      Last := Last - 1;
   end Pop;

   procedure Play (P : Position; V : Slot) is
   begin
      if V /= Empty then
         My_Board (P.X) (P.Y) := V;
      end if;
   end Play;

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

   procedure Initialize is
   begin
      My_Board := (others => (others => Empty));
      Clear;
   end Initialize;

   procedure Player_Play (S : String) is
   begin
      if S'Length >= 1 then
         declare
            C : Character := S (S'First);
            P : Position := (1, 1);
            Found : Boolean := True;
         begin
            case C is
               when '1' => P := (1, 1);
               when '2' => P := (2, 1);
               when '3' => P := (3, 1);
               when '4' => P := (1, 2);
               when '5' => P := (2, 2);
               when '6' => P := (3, 2);
               when '7' => P := (1, 3);
               when '8' => P := (2, 3);
               when '9' => P := (3, 3);
               when others => Found := False;
            end case;

            if Found and then My_Board (P.X) (P.Y) = Empty then
               Play (P, Player);
            end if;
         end;
      end if;
   end Player_Play;

   procedure Computer_Play is
      Score : Integer;
      Target_Scores : array (1 .. 2) of Integer := (2, 20);
      P : Position;
   begin
      for Target_Score of Target_Scores loop
         for S of All_Solutions loop
            Score := 0;

            for I in S'Range loop
               P := S (I);
               if My_Board (P.X) (P.Y) = Computer then
                  Score := Score + 1;
               elsif My_Board (P.X) (P.Y) = Player then
                  Score := Score + 10;
               end if;
            end loop;

            if Score = Target_Score then
               for P of S loop
                  if My_Board (P.X) (P.Y) = Empty then
                     Play (P, Computer);
                     return;
                  end if;
               end loop;
            end if;
         end loop;
      end loop;

      for I in My_Board'Range loop
         for J in My_Board (I)'Range loop
            if My_Board (I) (J) = Empty then
               Play ((I, J), Computer);
               return;
            end if;
         end loop;
      end loop;
   end Computer_Play;

   procedure Display is
   begin
      for J in reverse Pos loop
         for I in Pos loop
            case My_Board (I) (J) is
               when Empty => Put (".");
               when Player => Put ("X");
               when Computer => Put ("O");
            end case;
         end loop;
         New_Line;
      end loop;
   end Display;

   function Won return Slot is
      Score : Integer;
      P : Position;
   begin
      for S of All_Solutions loop
         Score := 0;

         for I in S'Range loop
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

   -- Main game loop
   Player_Turn : Boolean := True;
   S : String (1 .. 10);
   Last_Size : Integer;

begin
   Initialize;

   loop
      if Player_Turn then
         Put_Line ("Player");
         Put ("Enter position (1-9) or 'u' to undo: ");
         Get_Line (S, Last_Size);

         if Last_Size >= 1 and then S (1) = 'u' then
            if Size > 0 then
               declare
                  Old_Board : Board;
               begin
                  Pop (Old_Board);
                  My_Board := Old_Board;
               end;
            end if;
            Display;
         else
            if Size < 9 then
               Push (My_Board);
            end if;
            Player_Play (S (1 .. Last_Size));
            Player_Turn := not Player_Turn;
            Display;
         end if;
      else
         Put_Line ("Computer");
         Computer_Play;
         Player_Turn := not Player_Turn;
         Display;
      end if;

      exit when Is_Full or Won /= Empty;
   end loop;

   case Won is
      when Computer =>
         Put_Line ("Really, losing against tic tac toe???");
      when Player =>
         Put_Line ("Will try using a deep learning algorithm next time...");
      when Empty =>
         Put_Line ("What's the other kind?");
   end case;

end Tictactoe;
