------------------------------------------------------------------------------
--                        M A G I C   R U N T I M E                         --
--                                                                          --
--                       Copyright (C) 2021, AdaCore                        --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Strings.Wide_Wide_Unbounded; use Ada.Strings.Wide_Wide_Unbounded;

with UCD.Characters;
with UCD.Data_File_Loaders;
with UCD.Properties;

package body UCD.Emoji_Data_Loader is

   ----------
   -- Load --
   ----------

   procedure Load (UCD_Root : Wide_Wide_String) is
      Name_Field : constant Data_File_Loaders.Field_Index := 1;
      --  Index of the data field with name of the property.

      Loader : UCD.Data_File_Loaders.File_Loader;

   begin
      --  Unicode 13.0: exception: Extended_Pictographic property is Y by
      --  default for unassigned code points in few ranges.

      declare
         use type UCD.Properties.Property_Value_Access;

         GC_Property      : constant not null Properties.Property_Access :=
           Properties.Resolve ("gc");
         GC_Unassigned    : constant not null
           Properties.Property_Value_Access :=
             Properties.Resolve (GC_Property, "Cn");
         ExtPict_Property : constant not null Properties.Property_Access :=
           Properties.Resolve ("ExtPict");
         ExtPict_Y        : constant not null
           Properties.Property_Value_Access :=
             Properties.Resolve (ExtPict_Property, "Y");
         ExtPict_N        : constant not null
           Properties.Property_Value_Access :=
             Properties.Resolve (ExtPict_Property, "N");

      begin
         for C in UCD.Code_Point loop
            if C in 16#01_F000# .. 16#01_FAFF# | 16#01_FC00# .. 16#01_FFFD#
            then
               if UCD.Characters.Get (C, GC_Property) = GC_Unassigned then
                  UCD.Characters.Set (C, ExtPict_Property, ExtPict_Y);

               else
                  UCD.Characters.Set (C, ExtPict_Property, ExtPict_N);
               end if;

            else
               UCD.Characters.Set (C, ExtPict_Property, ExtPict_N);
            end if;
         end loop;
      end;

      Loader.Open (UCD_Root, "emoji/emoji-data.txt");

      while not Loader.End_Of_File loop
         declare
            First_Code : UCD.Code_Point;
            Last_Code  : UCD.Code_Point;

         begin
            Loader.Get_Code_Point_Range (First_Code, Last_Code);

            declare
               Property : constant not null Properties.Property_Access :=
                 Properties.Resolve (Loader.Get_Field (Name_Field));

            begin
               for Code in First_Code .. Last_Code loop
                  Characters.Set
                    (Code, Property, Property.Name_To_Value.Element
                       (To_Unbounded_Wide_Wide_String ("Y")));
               end loop;
            end;

            Loader.Skip_Line;
         end;
      end loop;
   end Load;

end UCD.Emoji_Data_Loader;
