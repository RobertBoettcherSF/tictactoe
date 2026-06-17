package body Stack
with SPARK_Mode => On
is

   -- Version 2: Fixed gnatprove warnings
   -- - Added intermediate assertions in Push and Pop to help gnatprove connect preconditions to operations

   Tab  : array (1 .. Max_Size) of Board := (others => (others => (others => Empty)));
   --  The stack. We push and pop pointers to Values.

   -----------
   -- Clear --
   -----------

   procedure Clear is
   begin
      Last := Tab'First - 1;
   end Clear;

   ----------
   -- Push --
   ----------

   procedure Push (V : Board) is
   begin
      -- Precondition not Full ensures Last < Max_Size, so Last + 1 <= Max_Size
      pragma Assert (Last < Max_Size);
      Last := Last + 1;
      Tab (Last) := V;
   end Push;

   ---------
   -- Pop --
   ---------

   procedure Pop (V : out Board) is
   begin
      -- Precondition not Empty ensures Last >= 1, so Tab(Last) is valid
      pragma Assert (Last >= 1);
      V := Tab (Last);
      Last := Last - 1;
   end Pop;

   ---------
   -- Top --
   ---------

   function Top return Board is
   begin
      return Tab (Last);
   end Top;

end Stack;
