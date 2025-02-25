with Ada.Characters.Wide_Wide_Latin_1;
with Ada.Strings.Wide_Wide_Fixed;
with Ada.Strings.Wide_Wide_Maps;
with Ada.Wide_Wide_Text_IO;

with VSS.Characters;
with VSS.Regular_Expressions;
with VSS.Strings;
with VSS.Strings.Cursors.Markers;
with VSS.Strings.Character_Iterators;
with VSS.Strings.Conversions;

procedure Test_RegExp_RE_Tests is
   pragma Assertion_Policy (Check);

   type Check_Kind is (Skip, Match, Dont_Match);

   type Check_Value (Kind : Check_Kind := Skip) is record
      case Kind is
         when Match =>
            Expr   : VSS.Strings.Virtual_String;
            Expect : VSS.Strings.Virtual_String;
         when others =>
            null;
      end case;
   end record;

   procedure Parse_Line
     (Line    : Wide_Wide_String;
      Pattern : out VSS.Strings.Virtual_String;
      Sample  : out VSS.Strings.Virtual_String;
      Check   : out Check_Value);

   procedure Verify
     (Line   : Wide_Wide_String;
      Match  : VSS.Regular_Expressions.Regular_Expression_Match;
      Expr   : VSS.Strings.Virtual_String;
      Expect : VSS.Strings.Virtual_String;
      Total  : in out Natural);

   function Image (Value : VSS.Strings.Character_Count)
     return VSS.Strings.Virtual_String;

   Space : constant Ada.Strings.Wide_Wide_Maps.Wide_Wide_Character_Set :=
     Ada.Strings.Wide_Wide_Maps.To_Set
       (Ada.Characters.Wide_Wide_Latin_1.HT);

   -----------
   -- Image --
   -----------

   function Image (Value : VSS.Strings.Character_Count)
     return VSS.Strings.Virtual_String
   is
      Img : constant Wide_Wide_String :=
        VSS.Strings.Character_Count'Wide_Wide_Image (Value);
   begin
      return VSS.Strings.To_Virtual_String (Img (2 .. Img'Last));
   end Image;

   ----------------
   -- Parse_Line --
   ----------------

   procedure Parse_Line
     (Line    : Wide_Wide_String;
      Pattern : out VSS.Strings.Virtual_String;
      Sample  : out VSS.Strings.Virtual_String;
      Check   : out Check_Value)
   is
      From : array (1 .. 5) of Positive;
      To   : array (0 .. 5) of Natural := (others => 0);
   begin
      --  Parse 5 columns
      --  1 => pattern
      --  2 => sample
      --  3 => has match
      --  4 => expression to evaluate
      --  5 => evaluated value
      for J in From'Range loop
         Ada.Strings.Wide_Wide_Fixed.Find_Token
           (Source => Line,
            Set    => Space,
            From   => To (J - 1) + 1,
            Test   => Ada.Strings.Outside,
            First  => From (J),
            Last   => To (J));
      end loop;

      Pattern := VSS.Strings.To_Virtual_String (Line (From (1) .. To (1)));
      Sample := VSS.Strings.To_Virtual_String (Line (From (2) .. To (2)));

      declare
         Status : constant Wide_Wide_String := Line (From (3) .. To (3));
         Expr   : constant Wide_Wide_String := Line (From (4) .. To (4));
         Expect : constant Wide_Wide_String := Line (From (5) .. To (5));
      begin
         case Status (Status'First) is
            when 'y' =>
               Check := (Match,
                         VSS.Strings.To_Virtual_String (Expr),
                         VSS.Strings.To_Virtual_String (Expect));
            when 'n' =>
               Check := (Kind => Dont_Match);
            when others =>   --  'c'  --  compile error
               Check := (Kind => Skip);
         end case;
      end;
   end Parse_Line;

   ------------
   -- Verify --
   ------------

   procedure Verify
     (Line   : Wide_Wide_String;
      Match  : VSS.Regular_Expressions.Regular_Expression_Match;
      Expr   : VSS.Strings.Virtual_String;
      Expect : VSS.Strings.Virtual_String;
      Total  : in out Natural)
   is
      use type VSS.Strings.Character_Count;
      use type VSS.Strings.Virtual_String;
      use type VSS.Characters.Virtual_Character;

      function Read_Natural
        (Cursor : in out VSS.Strings.Character_Iterators.Character_Iterator)
         return Natural;
      --  Read natural number from given cursor. Move the cursor to next char.

      function Read_Natural
        (Cursor : in out VSS.Strings.Character_Iterators.Character_Iterator)
         return Natural
      is
         To   : VSS.Strings.Cursors.Markers.Character_Marker;
         From : constant VSS.Strings.Cursors.Markers.Character_Marker :=
           Cursor.Marker;
      begin
         while Cursor.Element in '0' .. '9' loop
            To := Cursor.Marker;
            exit when not Cursor.Forward;
         end loop;

         return Natural'Wide_Wide_Value
           (VSS.Strings.Conversions.To_Wide_Wide_String
              (Expr.Slice (From, To)));
      end Read_Natural;

      Result : VSS.Strings.Virtual_String;
      Cursor : VSS.Strings.Character_Iterators.Character_Iterator :=
        Expr.First_Character;
   begin
      loop
         case Cursor.Element is
            when '$' =>
               pragma Assert (Cursor.Forward);

               case Cursor.Element is
                  when '&' =>  --  $& - whole match
                     Result.Append (Match.Captured);

                  when '1' .. '9' =>  --  $X - the X group
                     declare
                        Index : constant Positive := Read_Natural (Cursor);
                     begin
                        Result.Append (Match.Captured (Index));
                        --  step back to last digit:
                        pragma Assert (Cursor.Backward);
                     end;

                  when '-' =>  --  &-[X] - the X group start offset
                     pragma Assert (Cursor.Forward);
                     pragma Assert (Cursor.Element = '[');
                     pragma Assert (Cursor.Forward);
                     pragma Assert (Cursor.Element in '0' .. '9');

                     declare
                        Index : constant Natural := Read_Natural (Cursor);

                        Marker : constant
                          VSS.Strings.Cursors.Markers.Character_Marker :=
                            Match.First_Marker (Index);
                     begin
                        Result.Append (Image (Marker.Character_Index - 1));
                     end;

                     pragma Assert (Cursor.Element = ']');

                  when '+' =>  --  &+[X] - the X group end offset
                     pragma Assert (Cursor.Forward);
                     pragma Assert (Cursor.Element = '[');
                     pragma Assert (Cursor.Forward);
                     pragma Assert (Cursor.Element in '0' .. '9');

                     declare
                        Index : constant Natural := Read_Natural (Cursor);

                        Marker : constant
                          VSS.Strings.Cursors.Markers.Character_Marker :=
                            Match.Last_Marker (Index);
                     begin
                        Result.Append (Image (Marker.Character_Index));
                     end;

                     pragma Assert (Cursor.Element = ']');

                  when others =>
                     raise Program_Error;
               end case;
            when others =>
               Result.Append (Cursor.Element);
         end case;

         exit when not Cursor.Forward;
      end loop;

      if Result = Expect then
         Total := Total + 1;  --  PASS
      else
         Ada.Wide_Wide_Text_IO.Put ("DIFF: ");
         Ada.Wide_Wide_Text_IO.Put (Line);
         Ada.Wide_Wide_Text_IO.Put (" /= <");
         Ada.Wide_Wide_Text_IO.Put
           (VSS.Strings.Conversions.To_Wide_Wide_String (Result));
         Ada.Wide_Wide_Text_IO.Put_Line (">");
      end if;
   end Verify;

   Total : Natural := 0;

   Last_Pattern : VSS.Regular_Expressions.Regular_Expression;
   Last_Sample  : VSS.Strings.Virtual_String;
   Last_Match   : VSS.Regular_Expressions.Regular_Expression_Match;

begin
   while not Ada.Wide_Wide_Text_IO.End_Of_File loop
      declare
         Line : constant Wide_Wide_String := Ada.Wide_Wide_Text_IO.Get_Line;
      begin
         if Line in "" | "__END__"
           or else Line (1) = '#'
         then
            --  skip comments and special lines
            null;
         elsif Line (1) not in ''' | '/' then
            declare
               use type VSS.Strings.Virtual_String;

               Pattern : VSS.Strings.Virtual_String;
               Sample  : VSS.Strings.Virtual_String;
               Check   : Check_Value;
            begin
               Parse_Line (Line, Pattern, Sample, Check);

               if Check.Kind /= Skip then
                  if Last_Pattern.Pattern /= Pattern then
                     Last_Pattern :=
                       VSS.Regular_Expressions.To_Regular_Expression (Pattern);

                     Last_Sample := VSS.Strings.Empty_Virtual_String;
                  end if;

                  if Last_Sample /= Sample then
                     Last_Sample := Sample;
                     Last_Match := Last_Pattern.Match (Sample);
                  end if;

                  case Check.Kind is
                     when Match =>
                        if Last_Match.Has_Match then
                           Verify
                             (Line,
                              Last_Match,
                              Check.Expr,
                              Check.Expect,
                              Total);
                        else
                           Ada.Wide_Wide_Text_IO.Put ("DONT: ");
                           Ada.Wide_Wide_Text_IO.Put_Line (Line);
                        end if;
                     when Dont_Match =>
                        if Last_Match.Has_Match then
                           Ada.Wide_Wide_Text_IO.Put ("MISS: ");
                           Ada.Wide_Wide_Text_IO.Put_Line (Line);
                        else
                           Total := Total + 1;  --  PASS
                        end if;
                     when Skip =>
                        null;
                  end case;
               else
                  Ada.Wide_Wide_Text_IO.Put ("SKIP: ");
                  Ada.Wide_Wide_Text_IO.Put_Line (Line);
               end if;
            exception
               when others =>
                  Ada.Wide_Wide_Text_IO.Put ("CRASH: ");
                  Ada.Wide_Wide_Text_IO.Put_Line (Line);
            end;
         end if;
      end;
   end loop;

   Ada.Wide_Wide_Text_IO.Put_Line (Total'Wide_Wide_Image);
end Test_RegExp_RE_Tests;
