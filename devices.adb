with Ada.Text_IO; use Ada.Text_IO;
with System;      use System;
with tools;       use tools;
with control;     use control;

package body devices is
   SENSOR_VELOCIDAD : constant Integer := 3;
   SENSOR_VOLANTE   : constant Integer := 2;

   procedure Reading_Speed (V : out Speed_Samples_Type) is
   begin
      V := Speed_Samples_Type (Leer_Sensor (SENSOR_VELOCIDAD) * 200 / 1_024);
   end Reading_Speed;

   procedure Reading_HeadPosition (H : out HeadPosition_Samples_Type) is
   begin
      H := (0, 0);
   end Reading_HeadPosition;

   procedure Reading_Distance (L : out Distance_Samples_Type) is
   begin
      L := Distance_Samples_Type (0);
   end Reading_Distance;

   procedure Reading_Steering (S : out Steering_Samples_Type) is
   begin
      S :=
        Steering_Samples_Type
          ((Leer_Sensor (SENSOR_VOLANTE) * 360 / 1_024) - 180);
   end Reading_Steering;

   -----------------------------------------------------------------------------
   procedure Display_Distance (D : Distance_Samples_Type) is
   begin
      Current_Time (Big_Bang);
      Put ("............# ");
      Put ("Distance: ");
      Print_an_Integer (Integer (D));
   end Display_Distance;
   -----------------------------------------------------------------------------
   procedure Display_Speed (V : Speed_Samples_Type) is
   begin
      Current_Time (Big_Bang);
      Put ("............# ");
      Put ("Speed: ");
      Print_an_Integer (Integer (V));
   end Display_Speed;
   -----------------------------------------------------------------------------
   procedure Display_Steering (S : Steering_Samples_Type) is
   begin
      Current_Time (Big_Bang);
      Put ("............# ");
      Put ("Steering: ");
      Print_an_Integer (Integer (S));
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
   end Display_HeadPosition_Sample;
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
      --Lectura_EyesImage.Reaction (EYES_REACTION_WHEN_BEEP);
   end Beep;
   -----------------------------------------------------------------------------

   procedure Activate_Automatic_Driving is
   begin
      Current_Time (Big_Bang);
      Put ("!!!! Automatic driving system activated !!!!");
   end Activate_Automatic_Driving;
   -----------------------------------------------------------------------------

   procedure Activate_Brake is
   begin
      Current_Time (Big_Bang);
      Put ("!!!! Brake activated !!!!");
   end Activate_Brake;

   ---------------------------------------------------------------------------------------
begin
   null;
end devices;
