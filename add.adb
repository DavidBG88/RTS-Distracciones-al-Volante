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

   -----------------------------------------------------------------------
   ------------- declaration of types
   -----------------------------------------------------------------------

   type Sintoma_Distancia_Type is (Segura, Insegura, Imprudente, Colision);

   -----------------------------------------------------------------------
   ------------- declaration of auxiliary methods
   -----------------------------------------------------------------------

   procedure Starting_Notice (Task_Name : in String);
   procedure Finishing_Notice (Task_Name : in String);
   function Number_Sign (Number : Integer) return Integer;
   procedure Riesgo_Cabeza
     (Cabeza      : in     HeadPosition_Samples_Type;
      Volante     : in     Steering_Samples_Type; Prev_X_Risk : in Boolean;
      Prev_Y_Risk : in     Boolean; X_Risk : out Boolean; Y_Risk : out Boolean;
      Risk        :    out Boolean);
   procedure Riesgo_Distancia
     (Velocidad : in Speed_Samples_Type; Distancia : in Distance_Samples_Type;
      Risk      :    out Sintoma_Distancia_Type);

   ----------------------------------------------------------------------
   ------------- declaration of protected objects
   ----------------------------------------------------------------------

   protected Sintomas is
      procedure Update_Cabeza (Risk : Boolean);
      procedure Update_Distancia (Risk : Sintoma_Distancia_Type);
      procedure Run_Riesgos;
      procedure Update_Volante (Risk : Boolean);
      procedure Run_Display;
   private
      Riesgo_Cabeza    : Boolean                := False;
      Riesgo_Distancia : Sintoma_Distancia_Type := Segura;
      Riesgo_Volante   : Boolean                := False;
   end Sintomas;

   protected Medidas is
      procedure Update_Distancia (Distancia : in Distance_Samples_Type);
      procedure Update_Velocidad (Velocidad : in Speed_Samples_Type);
      procedure Run_Riesgos;
      procedure Run_Display;
   private
      Distancia : Distance_Samples_Type := 0;
      Velocidad : Speed_Samples_Type    := 0;
   end Medidas;

   ----------------------------------------------------------------------
   ------------- definition of protected objects
   ----------------------------------------------------------------------

   protected body Sintomas is
      procedure Update_Cabeza (Risk : Boolean) is
      begin
         Riesgo_Cabeza := Risk;
      end Update_Cabeza;

      procedure Update_Distancia (Risk : Sintoma_Distancia_Type) is
         Speed           : Speed_Samples_Type    := 0;
         Distance        : Distance_Samples_Type := 0;
         Safety_Distance : Float                 := 0.0;
      begin
         Riesgo_Distancia := Risk;
      end Update_Distancia;

      procedure Update_Volante (Risk : Boolean) is
      begin
         Riesgo_Volante := Risk;
      end Update_Volante;
   end Sintomas;

   protected body Medidas is
      procedure Update_Distancia (Distancia : in Distance_Samples_Type) is
      begin
         Medidas.Distancia := Distancia;
      end Update_Distancia;

      procedure Update_Velocidad (Velocidad : in Speed_Samples_Type) is
      begin
         Medidas.Velocidad := Velocidad;
      end Update_Velocidad;
   end Medidas;

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
      Task_Name   : constant String   := "Cabeza";
      Task_Period : constant Duration := 0.400;

      Head_Position  : HeadPosition_Samples_Type := (0, 0);
      Steering_Angle : Steering_Samples_Type     := 0;
      Prev_X_Risk    : Boolean                   := False;
      Prev_Y_Risk    : Boolean                   := False;
      X_Risk         : Boolean                   := False;
      Y_Risk         : Boolean                   := False;
      Head_Risk      : Boolean                   := False;
   begin
      loop
         Starting_Notice (Task_Name);

         Reading_HeadPosition (Head_Position);
         Riesgo_Cabeza
           (Head_Position, Steering_Angle, Prev_X_Risk, Prev_Y_Risk, X_Risk,
            Y_Risk, Head_Risk);
         Sintomas.Update_Cabeza (Head_Risk);

         Finishing_Notice (Task_Name);
         delay (Task_Period);
      end loop;
   end Cabeza;

   task body Distancia is
      task_name   : constant String   := "Distancia";
      task_period : constant Duration := 0.300;

      Distance_Risk : Sintoma_Distancia_Type := Segura;
      Distance      : Distance_Samples_Type  := 0;
      Speed         : Speed_Samples_Type     := 0;
   begin
      loop
         Starting_Notice (task_name);

         Reading_Speed (Speed);
         Reading_Distance (Distance);

         Riesgo_Distancia (Speed, Distance, Distance_Risk);
         Sintomas.Update_Distancia (Distance_Risk);

         -- Medidas.Update_Distancia;
         -- Medidas.Update_Velocidad;

         Finishing_Notice (task_name);
         delay (task_period);
      end loop;
   end Distancia;

   task body Volante is
      task_name   : constant String   := "Volante";
      task_period : constant Duration := 0.350;
   begin
      loop
         Starting_Notice (task_name);
         -- Sintomas.Update_Volante;
         Finishing_Notice (task_name);
         delay (task_period);
      end loop;
   end Volante;

   task body Riesgos is
      task_name   : constant String   := "Riesgos";
      task_period : constant Duration := 0.150;
   begin
      loop
         Starting_Notice (task_name);

         -- Task code here

         Finishing_Notice (task_name);
         delay (task_period);
      end loop;
   end Riesgos;

   task body Display is
      task_name   : constant String   := "Display";
      task_period : constant Duration := 1.000;
   begin
      loop
         Starting_Notice (task_name);

         -- Task code here

         Finishing_Notice (task_name);
         delay (task_period);
      end loop;
   end Display;

   task body Modo is
      task_name   : constant String   := "Modo";
      task_period : constant Duration := 0.3;
   begin
      loop
         Starting_Notice (task_name);

         -- Task code here

         Finishing_Notice (task_name);
         delay (task_period);
      end loop;
   end Modo;

   -----------------------------------------------------------------------
   ------------- body of auxiliary methods
   -----------------------------------------------------------------------

   procedure Starting_Notice (task_name : in String) is
   begin
      Put_Line ("Comenzando tarea " & task_name);
   end Starting_Notice;

   procedure Finishing_Notice (task_name : in String) is
   begin
      Put_Line ("Finalizando tarea " & task_name);
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

   procedure Riesgo_Cabeza
     (Cabeza      : in     HeadPosition_Samples_Type;
      Volante     : in     Steering_Samples_Type; Prev_X_Risk : in Boolean;
      Prev_Y_Risk : in     Boolean; X_Risk : out Boolean; Y_Risk : out Boolean;
      Risk        :    out Boolean)
   is
      Current_X_Risk         : Boolean := False;
      Current_Y_Risk         : Boolean := False;
      Wheel_And_Head_Aligned : Boolean := False;
      Total_X_Risk           : Boolean := False;
      Total_Y_Risk           : Boolean := False;
   begin
      Current_X_Risk := abs (Cabeza (x)) > 30;
      Current_Y_Risk := abs (Cabeza (y)) > 30;

      Total_X_Risk := Current_X_Risk and Prev_X_Risk;

      Wheel_And_Head_Aligned :=
        Number_Sign (Integer (Volante)) = Number_Sign (Integer (Cabeza (y)));
      Total_Y_Risk           :=
        Current_Y_Risk and Prev_Y_Risk and abs (Volante) <= 30 and
        not Wheel_And_Head_Aligned;

      if Total_X_Risk or Total_Y_Risk then
         Risk := True;
      end if;

      X_Risk := Current_X_Risk;
      Y_Risk := Current_Y_Risk;
   end Riesgo_Cabeza;

   procedure Riesgo_Distancia
     (Velocidad : in Speed_Samples_Type; Distancia : in Distance_Samples_Type;
      Risk      :    out Sintoma_Distancia_Type)
   is
      Safety_Distance : Float := 0.0;
   begin
      Safety_Distance := (Float (Velocidad) / 10.0)**2;

      if Float (Distancia) < Safety_Distance / 3.0 then
         Risk := Colision;
      elsif Float (Distancia) < Safety_Distance / 2.0 then
         Risk := Imprudente;
      elsif Float (Distancia) < Safety_Distance then
         Risk := Insegura;
      else
         Risk := Segura;
      end if;
   end Riesgo_Distancia;

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
