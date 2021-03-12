------------------------------------------------------------------------------
--                        M A G I C   R U N T I M E                         --
--                                                                          --
--                       Copyright (C) 2020, AdaCore                        --
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

package body VSS.Stream_Element_Buffers.Internals is

   --------------------------
   -- Data_Constant_Access --
   --------------------------

   procedure Data_Constant_Access
     (Self    : Stream_Element_Buffer'Class;
      Length  : out Ada.Streams.Stream_Element_Count;
      Storage : out Stream_Element_Array_Access) is
   begin
      if Self.Data /= null then
         Length  := Self.Data.Length;
         Storage := Self.Data.Storage'Unrestricted_Access;

      else
         Length  := 0;
         Storage := null;
      end if;
   end Data_Constant_Access;

end VSS.Stream_Element_Buffers.Internals;
