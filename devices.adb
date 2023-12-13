with Kernel.Serial_Output; use Kernel.Serial_Output;
with System;               use System;
with tools;                use tools;

package body devices is
   procedure Reading_Speed (V : out Speed_Samples_Type) is
   begin
      V := 0;
   end Reading_Speed;

   procedure Reading_HeadPosition (H : out HeadPosition_Samples_Type) is
   begin
      H := (0, 0);
   end Reading_HeadPosition;

   procedure Reading_Steering (S : out Steering_Samples_Type) is
   begin
      S := 20;
   end Reading_Steering;

   -----------------------------------------------------------------------------
   procedure Display_Distance (D : Distance_Samples_Type) is
   begin
      Current_Time (Big_Bang);
      Put ("............# ");
      Put ("Distance: ");
      Print_an_Integer (Integer (D));
      Execution_Time (WCET_Distance);
   end Display_Distance;
   -----------------------------------------------------------------------------
   procedure Display_Speed (V : Speed_Samples_Type) is
   begin
      Current_Time (Big_Bang);
      Put ("............# ");
      Put ("Speed: ");
      Print_an_Integer (Integer (V));
      Execution_Time (WCET_Speed);
   end Display_Speed;
   -----------------------------------------------------------------------------
   procedure Display_Steering (S : Steering_Samples_Type) is
   begin
      Current_Time (Big_Bang);
      Put ("............# ");
      Put ("Steering: ");
      Print_an_Integer (Integer (S));
      Execution_Time (WCET_Steering);
   end Display_Steering;
   ---------------------------------------------------------------------
   procedure Display_HeadPosition_Sample (H : HeadPosition_Samples_Type) is

   begin
      Current_Time (Big_Bang);
      Put ("............# ");
      Put ("HeadPosition: ");
      for i in HeadPosition_Samples_Index loop
         Print_an_Integer (Integer (H (i)));
      end loop;
      Execution_Time (WCET_Display);
   end Display_HeadPosition_Sample;
   -----------------------------------------------------------------------------
   procedure Display_Eyes_Sample (R : Eyes_Samples_Type) is
      Average : Eyes_Samples_Values;
   begin
      Current_Time (Big_Bang);
      Put ("............# ");
      Put ("Eyes Openness: ");
      for i in Eyes_Samples_Index loop
         Print_an_Integer (Integer (R (i)));
      end loop;

      Average := (R (right) + R (left)) / 2;
      if Average > 80 then
         Put ("   (O,O)");
      elsif Average > 60 then
         Put ("   (o,o)");
      elsif Average > 30 then
         Put ("   (*,*)");
      else
         Put ("   (-,-)");
      end if;

      Execution_Time (WCET_Display);
   end Display_Eyes_Sample;
   -----------------------------------------------------------------------------
   procedure Display_Cronometro
     (Origen : Ada.Real_Time.Time; Hora : Ada.Real_Time.Time)
   is
      type Crono is delta 0.1 range 0.0 .. 100.0;
   begin
      Current_Time (Big_Bang);
      Put ("............%Crono:");
      --Put (Duration'Image(To_Duration(Clock - Origen)));
      Put (Crono'Image (Crono (To_Duration (Hora - Origen))));
   end Display_Cronometro;
   -----------------------------------------------------------------------------

   procedure Light (E : Light_States) is
   begin
      Current_Time (Big_Bang);
      case E is
         when On =>
            Put ("............Light: ^ON^");
         when Off =>
            Put ("............Light: _off_");
      end case;
      Execution_Time (WCET_Light);
   end Light;

   -----------------------------------------------------------------------------

   procedure Beep (v : Volume) is
   -- emite un sonido durante 0.3 segundos con volumne "v"
   begin
      Current_Time (Big_Bang);

      Put ("............%B");
      for i in 1 .. v loop
         Put ("EE");
      end loop;
      Put ("P");
      Put (Volume'Image (v));
      Execution_Time (WCET_Alarm);
      --Lectura_EyesImage.Reaction (EYES_REACTION_WHEN_BEEP);
   end Beep;
   -----------------------------------------------------------------------------

   procedure Activate_Automatic_Driving is
   begin
      Current_Time (Big_Bang);
      Put ("!!!! Automatic driving system activated !!!!");
      Execution_Time (WCET_Automatic_Driving);
   end Activate_Automatic_Driving;
   -----------------------------------------------------------------------------

   procedure Activate_Brake is
   begin
      Current_Time (Big_Bang);
      Put ("!!!! Brake activated !!!!");
      Execution_Time (WCET_Brake);
   end Activate_Brake;

   ---------------------------------------------------------------------------------------
begin
   null;
end devices;
