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
   procedure Starting_Notice(task_name: in String) is
   begin
      Put("Comenzando tarea " & task_name);
   end Starting_Notice;

   procedure Finishing_Notice(task_name: in String) is
   begin
      Put("Finalizando tarea " & task_name);
   end Starting_Notice;

   function Number_Sign(Number: Integer) return Integer is
   begin
      if (number > 0) then 
         return 1;
      else if number < 0 then
         return -1;
      end if;

      return 0;
   end Number_Sign;

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
   ------------- body of tasks
   -----------------------------------------------------------------------

   task body Cabeza is
      task_name : constant String := "Cabeza";
      task_period : constant Natural := 400;
         
      Head_Position: HeadPosition_Samples_Type;
      Wheel_Position: Steering_Samples_Type;
      Current_X_Danger: Boolean := False;
      Current_Y_Danger: Boolean := False;
      Previous_X_Danger: Boolean := False;
      Previous_Y_Danger: Boolean := False;
   begin
      loop
         Starting_Notice(task_name);

         Reading_HeadPosition(Head_Position);
         Reading_Steering(Wheel_Position);

         Current_X_Danger := Abs(Head_Position(x)) > 30;
         Current_Y_Danger := Abs(Head_Position(y)) > 30;

         if Current_X_Danger and Previous_X_Danger then
            -- Alerta
         end if;

         if Current_Y_Danger and Previous_Y_Danger 
               and Number_Sign(Wheel_Position) = Number_Sign(HeadPosition(y)) then
            -- Alerta
         end if;

         Previous_X_danger := Current_X_Danger;
         Previous_Y_danger := Current_Y_Danger;

         Finishing_Notice(task_name);

         -- Delay here
         delay(task_period);
      end loop;
   end Cabeza;

   task body Distancia is
      task_name : constant String := "Distancia";
   begin
      loop
         Starting_Notice(task_name);
         Finishing_Notice(task_name);

         -- Delay here
      end loop;
   end Cabeza;

task body Volante is
      task_name : constant String := "Distancia";
   begin
      loop
         Starting_Notice(task_name);
         Finishing_Notice(task_name);

         -- Delay here
      end loop;
   end Cabeza;

   task body Riesgos is
      task_name : constant String := "Distancia";
   begin
      loop
         Starting_Notice(task_name);
         Finishing_Notice(task_name);

         -- Delay here
      end loop;
   end Cabeza;

   task body Display is
      task_name : constant String := "Distancia";
   begin
      loop
         Starting_Notice (task_name);
         Finishing_Notice (task_name);

         -- Delay here
      end loop;
   end Cabeza;

   task body Modo is
      task_name : constant String := "Distancia";
   begin
      loop
         Starting_Notice (task_name);
         Finishing_Notice (task_name);

         -- Delay here
      end loop;
   end Cabeza;

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
