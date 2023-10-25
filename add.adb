with Ada.Text_IO; use Ada.Text_IO; -- compilador gnat
-- with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System;        use System;

with tools;   use tools;
with devices; use devices;

-- Packages needed to generate pulse interrupts
-- with Ada.Interrupts.Names;
-- with Pulse_Interrupt; use Pulse_Interrupt;

package body add is
   ----------------------------------------------------------------------
   ------------- procedure exported
   ----------------------------------------------------------------------

   procedure Background is
   begin
      loop
         null;
      end loop;
   end Background;

   ----------------------------------------------------------------------
   ------------- declaration of protected objects
   ----------------------------------------------------------------------

   protected Sintomas is
      procedure Run_Cabeza;
      procedure Run_Volante;
   private
      Cabeza_Inclinada : Boolean := False;

      Distancia_Insegura   : Boolean := False;
      Distancia_Imprudente : Boolean := False;
      Distancia_Colision   : Boolean := False;
   end Sintomas;

   ----------------------------------------------------------------------
   ------------- definition of protected objects
   ----------------------------------------------------------------------

   protected body Sintomas is
      procedure Run_Cabeza is
         Head_Position     : HeadPosition_Samples_Type;
         Wheel_Position    : Steering_Samples_Type;
         Current_X_Danger  : Boolean := False;
         Current_Y_Danger  : Boolean := False;
         Previous_X_Danger : Boolean := False;
         Previous_Y_Danger : Boolean := False;
      begin
         loop
            Reading_HeadPosition (Head_Position);
            Reading_Steering (Wheel_Position);

            Current_X_Danger := abs (Head_Position (x)) > 30;
            Current_Y_Danger := abs (Head_Position (y)) > 30;

            if (Current_X_Danger and Previous_X_Danger) or
              (Current_Y_Danger and Previous_Y_Danger and
               abs (Wheel_Position) <= 30 and
               Number_Sign (Wheel_Position) /= Number_Sign (HeadPosition (y)))
            then
               Cabeza_Inclinada := True;
            end if;

            Previous_X_Danger := Current_X_Danger;
            Previous_Y_Danger := Current_Y_Danger;
         end loop;
      end Run_Cabeza;

      procedure Run_Volante is
         Distance       : Distance_Samples_Type;
         Velocity       : Speed_Samples_Type;
         SecureVelocity : Integer := (Velocity / 10) * (Velocity / 10);
      begin
         loop
            if Distance < SecureVelocity / 3 then
               Distancia_Colision   := True;
               Distancia_Imprudente := False;
               Distancia_Insegura   := False;
            elsif Distance < SecureVelocity / 2 then
               Distancia_Colision   := False;
               Distancia_Imprudente := True;
               Distancia_Insegura   := False;
            elsif Distance < SecureVelocity then
               Distancia_Colision   := False;
               Distancia_Imprudente := False;
               Distancia_Insegura   := True;
            else
               Distancia_Colision   := False;
               Distancia_Imprudente := False;
               Distancia_Insegura   := False;
            end if;
         end loop;
      end Run_Volante;
   end Sintomas;

   -----------------------------------------------------------------------
   ------------- declaration of tasks
   -----------------------------------------------------------------------

   task Cabeza;
   task Distancia;
   task Volante;
   task Riesgos;
   task Display;
   task Modo;

   -----------------------------------------------------------------------
   ------------- declaration auxiliary methods
   -----------------------------------------------------------------------

   procedure Starting_Notice (Task_Name : in String);
   procedure Finishing_Notice (Task_Name : in String);
   function Number_Sign (Number : Integer) return Integer;

   -----------------------------------------------------------------------
   ------------- body of tasks
   -----------------------------------------------------------------------

   task body Cabeza is
      Task_Name   : constant String  := "Cabeza";
      Task_Period : constant Natural := 400;
   begin
      Starting_Notice (Task_Name);
      Sintomas.Run_Cabeza;
      Finishing_Notice (Task_Name);
      delay (Task_Period);
   end Cabeza;

   task body Volante is
      task_name   : constant String  := "Volante";
      task_period : constant Natural := 300;
   begin
      Starting_Notice (task_name);
      Sintomas.Run_Volante;
      Finishing_Notice (task_name);
      delay (Task_Period);
   end Volante;

   -----------------------------------------------------------------------
   ------------- body of auxiliary methods
   -----------------------------------------------------------------------

   procedure Starting_Notice (task_name : in String) is
   begin
      Put ("Comenzando tarea " & task_name);
   end Starting_Notice;

   procedure Finishing_Notice (task_name : in String) is
   begin
      Put ("Finalizando tarea " & task_name);
   end Finishing_Notice;

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

   ----------------------------------------------------------------------
   ------------- procedure para probar los dispositivos
   ----------------------------------------------------------------------
   procedure Prueba_Dispositivos;

   procedure Prueba_Dispositivos is
      Current_V : Speed_Samples_Type        := 0;
      Current_H : HeadPosition_Samples_Type := (+2, -2);
      Current_D : Distance_Samples_Type     := 0;
      Current_O : Eyes_Samples_Type         := (70, 70);
      Current_E : EEG_Samples_Type          := (1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
      Current_S : Steering_Samples_Type     := 0;
   begin
      Starting_Notice ("Prueba_Dispositivo");

      for I in 1 .. 120 loop
         -- Prueba distancia
         --Reading_Distance (Current_D);
         --Display_Distance (Current_D);
         --if (Current_D < 40) then Light (On);
         --                    else Light (Off); end if;

         -- Prueba velocidad
         --Reading_Speed (Current_V);
         --Display_Speed (Current_V);
         --if (Current_V > 110) then Beep (2); end if;

         -- Prueba volante
         Reading_Steering (Current_S);
         Display_Steering (Current_S);
         if (Current_S > 30) or (Current_S < -30) then
            Light (On);
         else
            Light (Off);
         end if;

         -- Prueba Posicion de la cabeza
         --Reading_HeadPosition (Current_H);
         --Display_HeadPosition_Sample (Current_H);
         --if (Current_H(x) > 30) then Beep (4); end if;

         -- Prueba ojos
         --Reading_EyesImage (Current_O);
         --Display_Eyes_Sample (Current_O);

         -- Prueba electroencefalograma
         --Reading_Sensors (Current_E);
         --Display_Electrodes_Sample (Current_E);

         delay until (Clock + To_Time_Span (0.1));
      end loop;

      Finishing_Notice ("Prueba_Dispositivo");
   end Prueba_Dispositivos;

begin
   Starting_Notice ("Programa Principal");
   Prueba_Dispositivos;
   Finishing_Notice ("Programa Principal");
end add;
