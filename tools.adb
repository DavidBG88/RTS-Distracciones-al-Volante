with Ada.Text_IO;   use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
--use type Ada.Real_Time.Time_Span;
--with System; use System;

with Workload;
--with Kernel.Peripherals; use Kernel.Peripherals;
--use type Kernel.Peripherals.UART_Channel;

package body tools is

   ---------------------------------------------------------------------
   --     PROCEDIMIENTO QUE IMPRIME LA HORA                           --
   ---------------------------------------------------------------------
   procedure Current_Time (Origen : Ada.Real_Time.Time) is
   begin
      Put_Line ("");
      Put ("[");
      --Print_RTClok;
      --Put (" / ");
      Put (Duration'Image (To_Duration (Clock - Origen)));
      Put ("] ");
      -- Put_Line ("");
   end Current_Time;

   ---------------------------------------------------------------------
   --     PROCEDIMIENTO QUE SACA EL VALOR DE UN ENTERO POR LA UART    --
   ---------------------------------------------------------------------

   procedure Print_an_Integer (x : in Integer) is
   begin
      --Put ("(");
      Put (Integer'Image (x));
      --Put (")");
   end Print_an_Integer;

   ---------------------------------------------------------------------
   --     PROCEDIMIENTO QUE SACA EL VALOR DE UN FLOAT POR LA UART    --
   ---------------------------------------------------------------------

   procedure Print_a_Float (x : in Float) is
      type Float_Printable is digits 2;
      nx : Float_Printable;
   begin
      --Put ("(");
      nx := Float_Printable (x);
      Put (Float_Printable'Image (nx));
      --Put (")");
   end Print_a_Float;

   ---------------------------------------------------------------------
   --     PROCEDIMIENTO PARA AVISAR DEL ARRANQUE DE UNA TAREA         --
   ---------------------------------------------------------------------

   procedure Starting_Notice (T : in String) is
   begin
      null;
      --Current_Time (Big_Bang);
      --Put (">>> ");
      --Put (T);
   end Starting_Notice;

   procedure Finishing_Notice (T : in String) is
   begin
      null;
      --Current_Time (Big_Bang);
      --Put ("--- ");
      --Put (T);
   end Finishing_Notice;

   ---------------------------------------------------------------------
   --     PROCEDIMIENTO QUE HACE CALCULOS                             --
   ---------------------------------------------------------------------
   Time_per_Kwhetstones : constant Ada.Real_Time.Time_Span :=
     Ada.Real_Time.Nanoseconds (660_000); -- anterior (479936);

   procedure Execution_Time (Time : Ada.Real_Time.Time_Span) is

   begin
      Workload.Small_Whetstone (Time / Time_per_Kwhetstones);
   end Execution_Time;
   ---------------------------------------------------------------------

   function Number_Sign (Number : Integer) return Integer is
      Sign : Integer := 0;
   begin
      if (Number > 0) then
         Sign := 1;
      elsif Number < 0 then
         Sign := -1;
      end if;

      return Sign;
   end Number_Sign;

begin
   null;
end tools;
