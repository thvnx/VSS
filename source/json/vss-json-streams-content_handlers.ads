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
--  This package declares interface type to be used as abstract interface to
--  process JSON streams in callback style API.

with VSS.Strings;

package VSS.JSON.Streams.Content_Handlers is

   pragma Preelaborate;

   type JSON_Content_Handler is limited interface;

   type JSON_Content_Handler_Access is access all JSON_Content_Handler'Class;

   procedure Start_Document
     (Self : in out JSON_Content_Handler; Success : in out Boolean) is null;
   --  Called when processing of JSON document has been started

   procedure End_Document
     (Self : in out JSON_Content_Handler; Success : in out Boolean) is null;
   --  Called when processing of JSON document has need finished with any
   --  reason (document processed completely, document is invalid, processing
   --  is terminated by application). No other subprograms will be called
   --  before new call of Start_Document.

   procedure Start_Array
     (Self : in out JSON_Content_Handler; Success : in out Boolean) is null;

   procedure End_Array
     (Self : in out JSON_Content_Handler; Success : in out Boolean) is null;

   procedure Start_Object
     (Self : in out JSON_Content_Handler; Success : in out Boolean) is null;

   procedure End_Object
     (Self : in out JSON_Content_Handler; Success : in out Boolean) is null;

   procedure Key_Name
     (Self    : in out JSON_Content_Handler;
      Name    : VSS.Strings.Virtual_String'Class;
      Success : in out Boolean) is null;

   procedure String_Value
     (Self    : in out JSON_Content_Handler;
      Value   : VSS.Strings.Virtual_String'Class;
      Success : in out Boolean) is null;

   procedure Number_Value
     (Self    : in out JSON_Content_Handler;
      Value   : VSS.JSON.JSON_Number;
      Success : in out Boolean) is null;

   procedure Boolean_Value
     (Self    : in out JSON_Content_Handler;
      Value   : Boolean;
      Success : in out Boolean) is null;

   procedure Null_Value
     (Self : in out JSON_Content_Handler; Success : in out Boolean) is null;

   function Error_Message
     (Self : JSON_Content_Handler) return VSS.Strings.Virtual_String
      is abstract;
   --  Return diagnosis message for error detected by handler. Usually called
   --  by the reader to get diagnosis and provide it for higher level
   --  component.

   --  Convinience subprograms to report integer and float value using Ada
   --  types

   procedure Integer_Value
     (Self    : in out JSON_Content_Handler'Class;
      Value   : Interfaces.Integer_64;
      Success : in out Boolean);

   procedure Float_Value
     (Self    : in out JSON_Content_Handler'Class;
      Value   : Interfaces.IEEE_Float_64;
      Success : in out Boolean);

   --  Subprograms below are wrappers around subprograms with same name above
   --  that raise Assertion_Error exception in case then Success is set to
   --  False on return.

   procedure Start_Document (Self : in out JSON_Content_Handler'Class);

   procedure End_Document (Self : in out JSON_Content_Handler'Class);

   procedure Start_Array (Self : in out JSON_Content_Handler'Class);

   procedure End_Array (Self : in out JSON_Content_Handler'Class);

   procedure Start_Object (Self : in out JSON_Content_Handler'Class);

   procedure End_Object (Self : in out JSON_Content_Handler'Class);

   procedure Key_Name
     (Self : in out JSON_Content_Handler'Class;
      Name : VSS.Strings.Virtual_String'Class);

   procedure String_Value
     (Self  : in out JSON_Content_Handler'Class;
      Value : VSS.Strings.Virtual_String'Class);

   procedure Number_Value
     (Self  : in out JSON_Content_Handler'Class;
      Value : VSS.JSON.JSON_Number);

   procedure Integer_Value
     (Self  : in out JSON_Content_Handler'Class;
      Value : Interfaces.Integer_64);

   procedure Float_Value
     (Self  : in out JSON_Content_Handler'Class;
      Value : Interfaces.IEEE_Float_64);

   procedure Boolean_Value
     (Self  : in out JSON_Content_Handler'Class;
      Value : Boolean);

   procedure Null_Value (Self : in out JSON_Content_Handler'Class);

end VSS.JSON.Streams.Content_Handlers;
