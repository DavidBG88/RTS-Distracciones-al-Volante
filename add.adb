with Ada.Text_IO; use Ada.Text_IO; -- compilador gnat
-- with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System;        use System;

with tools;   use tools;
with devices; use devices;

-- Packages needed to generate pulse interrupts
with Ada.Interrupts.Names;
with pulse_interrupt; use pulse_interrupt;

----------------------------------------------------------------------
------------- tasks info
----------------------------------------------------------------------

-- | Task      | Period (ms) | Deadline (ms) | Priority |
-- | --------- | ----------- | ------------- | -------- |
-- | Cabeza    | 400         | 100           | 50       |
-- | Distancia | 300         | 300           | 30       |
-- | Volante   | 350         | 350           | 40       |
-- | Riesgos   | 150         | 150           | 10       |
-- | Display   | 1000        | 1000          | 60       |
-- | Modo      | X           | X             | 20       |

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
   type Modo_Sistema_Type is (M1, M2, M3);

   -----------------------------------------------------------------------
   ------------- declaration of auxiliary methods
   -----------------------------------------------------------------------

   procedure Starting_Notice (Task_Name : in String);
   procedure Finishing_Notice (Task_Name : in String);
   function Number_Sign (Number : Integer) return Integer;

   -----------------------------------------------------------------------
   ------------- declaration of packages
   -----------------------------------------------------------------------

   package Sensors is
      task Cabeza is
         pragma Priority (50);
      end Cabeza;
      task Distancia is
         pragma Priority (30);
      end Distancia;
      task Volante is
         pragma Priority (40);
      end Volante;
      task Modo is
         pragma Priority (20);
      end Modo;
   end Sensors;

   package Actuators is
      task Riesgos is
         pragma Priority (10);
      end Riesgos;
      task Display is
         pragma Priority (60);
      end Display;
   end Actuators;

   package State is
      protected Sintomas is
         procedure Update_Cabeza (Risk : Boolean);
         procedure Update_Distancia (Risk : Sintoma_Distancia_Type);
         procedure Update_Volante (Risk : Boolean);

         function Get_Cabeza return Boolean;
         function Get_Distancia return Sintoma_Distancia_Type;
         function Get_Volante return Boolean;
      private
         Riesgo_Cabeza    : Boolean                := False;
         Riesgo_Distancia : Sintoma_Distancia_Type := Segura;
         Riesgo_Volante   : Boolean                := False;
      end Sintomas;

      protected Medidas is
         procedure Update_Distancia (Distancia : in Distance_Samples_Type);
         procedure Update_Velocidad (Velocidad : in Speed_Samples_Type);

         function Get_Distancia return Distance_Samples_Type;
         function Get_Velocidad return Speed_Samples_Type;
      private
         Distancia : Distance_Samples_Type := 0;
         Velocidad : Speed_Samples_Type    := 0;
      end Medidas;

      protected Controlador_Modo is
         pragma Priority (System.Interrupt_Priority'First + 9);

         procedure Interrupcion;
         pragma Attach_Handler
           (Interrupcion, Ada.Interrupts.Names.External_Interrupt_2);

         entry Esperar_Modo;

         procedure Update_Modo_Sistema (Modo : in Modo_Sistema_Type);
         function Get_Modo_Sistema return Modo_Sistema_Type;
      private
         Llamada_Pendiente : Boolean           := False;
         Modo_Sistema      : Modo_Sistema_Type := M1;
      end Controlador_Modo;
   end State;

   ----------------------------------------------------------------------
   ------------- Sensors package definition
   ----------------------------------------------------------------------

   package body Sensors is
      use State;
      -- Auxiliary function declarations

      procedure Riesgo_Cabeza
        (Cabeza      : in     HeadPosition_Samples_Type;
         Volante     : in     Steering_Samples_Type; Prev_X_Risk : in Boolean;
         Prev_Y_Risk : in Boolean; X_Risk : out Boolean; Y_Risk : out Boolean;
         Risk        :    out Boolean);
      procedure Riesgo_Distancia
        (Velocidad : in     Speed_Samples_Type;
         Distancia : in     Distance_Samples_Type;
         Risk      :    out Sintoma_Distancia_Type);
      procedure Riesgo_Volante
        (Prev_Steering_Angle : in Steering_Samples_Type;
         Steering_Angle : in Steering_Samples_Type; Speed : Speed_Samples_Type;
         Prev_V_Risk : in Boolean; V_Risk : out Boolean; Risk : out Boolean);

      task body Cabeza is
         Task_Name   : constant String  := "Cabeza";
         Task_Period : constant Natural := 400;

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
            Reading_Steering (Steering_Angle);
            Riesgo_Cabeza
              (Head_Position, Steering_Angle, Prev_X_Risk, Prev_Y_Risk, X_Risk,
               Y_Risk, Head_Risk);
            Sintomas.Update_Cabeza (Head_Risk);
            Prev_X_Risk := X_Risk;
            Prev_Y_Risk := Y_Risk;

            Finishing_Notice (Task_Name);
            delay until (Clock + Milliseconds (Task_Period));
         end loop;
      end Cabeza;

      task body Distancia is
         Task_Name   : constant String  := "Distancia";
         Task_Period : constant Natural := 300;

         Distance_Risk : Sintoma_Distancia_Type := Segura;
         Distance      : Distance_Samples_Type  := 0;
         Speed         : Speed_Samples_Type     := 0;
      begin
         loop
            Starting_Notice (Task_Name);

            Reading_Speed (Speed);
            Reading_Distance (Distance);

            Riesgo_Distancia (Speed, Distance, Distance_Risk);
            Sintomas.Update_Distancia (Distance_Risk);
            Medidas.Update_Distancia (Distance);
            Medidas.Update_Velocidad (Speed);

            Finishing_Notice (Task_Name);
            delay until (Clock + Milliseconds (Task_Period));
         end loop;
      end Distancia;

      task body Volante is
         Task_Name   : constant String  := "Volante";
         Task_Period : constant Natural := 350;

         Risk                : Boolean               := False;
         V_Risk              : Boolean               := False;
         Prev_V_Risk         : Boolean               := False;
         Steering_Angle      : Steering_Samples_Type := 0;
         Prev_Steering_Angle : Steering_Samples_Type := 0;
         Speed               : Speed_Samples_Type    := 0;
      begin
         loop
            Starting_Notice (Task_Name);

            Reading_Steering (Steering_Angle);
            Riesgo_Volante
              (Prev_Steering_Angle, Steering_Angle, Speed, Prev_V_Risk, V_Risk,
               Risk);
            Prev_V_Risk         := V_Risk;
            Prev_Steering_Angle := Steering_Angle;
            Sintomas.Update_Volante (Risk);

            Finishing_Notice (Task_Name);
            delay until (Clock + Milliseconds (Task_Period));
         end loop;
      end Volante;

      task body Modo is
         Task_Name   : constant String  := "Modo";
         Task_Period : constant Natural := 100;

         Modo_Sistema : Modo_Sistema_Type := M1;
      begin
         loop
            Starting_Notice (Task_Name);

            Controlador_Modo.Esperar_Modo;

            Modo_Sistema := Controlador_Modo.Get_Modo_Sistema;

            if Modo_Sistema = M1 then
               if Sintomas.Get_Distancia /= Colision then
                  Controlador_Modo.Update_Modo_Sistema (M2);
               end if;
            elsif Modo_Sistema = M2 then
               if Sintomas.Get_Distancia /= Colision and
                 not Sintomas.Get_Cabeza
               then
                  Controlador_Modo.Update_Modo_Sistema (M3);
               end if;
            else
               Controlador_Modo.Update_Modo_Sistema (M1);
            end if;

            Finishing_Notice (Task_Name);
            delay until (Clock + Milliseconds (Task_Period));
         end loop;
      end Modo;

      -- Auxiliary function definitions

      procedure Riesgo_Cabeza
        (Cabeza      : in     HeadPosition_Samples_Type;
         Volante     : in     Steering_Samples_Type; Prev_X_Risk : in Boolean;
         Prev_Y_Risk : in Boolean; X_Risk : out Boolean; Y_Risk : out Boolean;
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
           Number_Sign (Integer (Volante)) =
           Number_Sign (Integer (Cabeza (y)));
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
        (Velocidad : in     Speed_Samples_Type;
         Distancia : in     Distance_Samples_Type;
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

      procedure Riesgo_Volante
        (Prev_Steering_Angle : in Steering_Samples_Type;
         Steering_Angle : in Steering_Samples_Type; Speed : Speed_Samples_Type;
         Prev_V_Risk : in Boolean; V_Risk : out Boolean; Risk : out Boolean)
      is
         Angle_Diff : Integer := 0;
      begin
         Angle_Diff :=
           abs (Integer (Steering_Angle) - Integer (Prev_Steering_Angle));
         V_Risk     := Angle_Diff >= 20 and Speed > 40;
         Risk       := Prev_V_Risk and V_Risk;
      end Riesgo_Volante;
   end Sensors;

   ----------------------------------------------------------------------
   ------------- Actuators package definition
   ----------------------------------------------------------------------

   package body Actuators is
      use State;

      task body Riesgos is
         Task_Name   : constant String  := "Riesgos";
         Task_Period : constant Natural := 150;

         Sintoma_Distancia : Sintoma_Distancia_Type := Segura;
         Sintoma_Volante   : Boolean                := False;
         Sintoma_Cabeza    : Boolean                := False;
         Medida_Velocidad  : Speed_Samples_Type     := 0;

         Beep_Intensity : Volume       := 1;
         Beep_Value     : Boolean      := False;
         Brake_Value    : Boolean      := False;
         Light_Value    : Light_States := Off;

         Modo_Sistema : Modo_Sistema_Type := M1;
      begin
         loop
            Starting_Notice (Task_Name);

            -- Store protected objects state

            Modo_Sistema := Controlador_Modo.Get_Modo_Sistema;

            if Modo_Sistema = M1 or Modo_Sistema = M2 then
               Sintoma_Distancia := Sintomas.Get_Distancia;
               Sintoma_Volante   := Sintomas.Get_Volante;
               Sintoma_Cabeza    := Sintomas.Get_Cabeza;
               Medida_Velocidad  := Medidas.Get_Velocidad;

               -- Update actuator values

               if Sintoma_Distancia = Colision and Sintoma_Cabeza then
                  Beep_Intensity := Volume'Max (5, Beep_Intensity);
                  Beep_Value     := True;
                  Brake_Value    := True;
               end if;

               if Modo_Sistema = M1 then
                  if Sintoma_Distancia = Insegura then
                     Light_Value := On;
                  elsif Sintoma_Distancia = Imprudente then
                     Beep_Intensity := Volume'Max (4, Beep_Intensity);
                     Beep_Value     := True;
                     Light_Value    := On;
                  end if;
               end if;

               if Sintoma_Cabeza then
                  if Medida_Velocidad > 70 then
                     Beep_Intensity := Volume'Max (3, Beep_Intensity);
                  else
                     Beep_Intensity := Volume'Max (2, Beep_Intensity);
                  end if;
               end if;

               if Sintoma_Volante and not Sintoma_Cabeza and
                 Sintoma_Distancia = Segura
               then
                  Beep_Intensity := 1;
               end if;

               -- Update actuators

               Light (Light_Value);
               if Beep_Value then
                  Beep (Beep_Intensity);
               end if;
               if Brake_Value then
                  Activate_Brake;
               end if;
            end if;

            Finishing_Notice (Task_Name);
            delay until (Clock + Milliseconds (Task_Period));
         end loop;
      end Riesgos;

      task body Display is
         Task_Name   : constant String  := "Display";
         Task_Period : constant Natural := 1_000;
      begin
         loop
            Starting_Notice (Task_Name);

            Put_Line
              ("Distancia: " &
               Distance_Samples_Type'Image (Medidas.Get_Distancia));
            Put_Line
              ("Velocidad: " &
               Speed_Samples_Type'Image (Medidas.Get_Velocidad));

            Put_Line ("Sintomas: ");
            if Sintomas.Get_Cabeza then
               Put_Line ("    Cabeza:    RIESGO");
            else
               Put_Line ("    Cabeza:    OK");
            end if;

            Put_Line
              ("    Distancia: " &
               Sintoma_Distancia_Type'Image (Sintomas.Get_Distancia));
            if Sintomas.Get_Volante then
               Put_Line ("    Volante:   RIESGO");
            else
               Put_Line ("    Volante:   OK");
            end if;

            Finishing_Notice (Task_Name);
            delay until (Clock + Milliseconds (Task_Period));
         end loop;
      end Display;
   end Actuators;

   ----------------------------------------------------------------------
   ------------- State package definition
   ----------------------------------------------------------------------

   package body State is
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

         function Get_Cabeza return Boolean is
         begin
            return Riesgo_Cabeza;
         end Get_Cabeza;

         function Get_Distancia return Sintoma_Distancia_Type is
         begin
            return Riesgo_Distancia;
         end Get_Distancia;

         function Get_Volante return Boolean is
         begin
            return Riesgo_Volante;
         end Get_Volante;
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

         function Get_Distancia return Distance_Samples_Type is
         begin
            return Medidas.Distancia;
         end Get_Distancia;

         function Get_Velocidad return Speed_Samples_Type is
         begin
            return Medidas.Velocidad;
         end Get_Velocidad;
      end Medidas;

      protected body Controlador_Modo is
         procedure Interrupcion is
         begin
            Llamada_Pendiente := True;
         end Interrupcion;

         entry Esperar_Modo when Llamada_Pendiente is
         begin
            Llamada_Pendiente := False;
         end Esperar_Modo;

         procedure Update_Modo_Sistema (Modo : in Modo_Sistema_Type) is
         begin
            Modo_Sistema := Modo;
         end Update_Modo_Sistema;

         function Get_Modo_Sistema return Modo_Sistema_Type is
         begin
            return Modo_Sistema;
         end Get_Modo_Sistema;
      end Controlador_Modo;

   end State;

   -----------------------------------------------------------------------
   ------------- body of auxiliary methods
   -----------------------------------------------------------------------

   procedure Starting_Notice (Task_Name : in String) is
   begin
      Put_Line ("Comenzando tarea " & Task_Name);
   end Starting_Notice;

   procedure Finishing_Notice (Task_Name : in String) is
   begin
      Put_Line ("Finalizando tarea " & Task_Name);
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
