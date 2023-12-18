with Ada.Real_Time; use Ada.Real_Time;

package devices is
  ---------------------------------------------------------------------
  ------ HeadPosition -------------------------------------------------

  type HeadPosition_Samples_Index is (x, y);
  type HeadPosition_Samples_Values is new Integer range -90 .. +90;
  type HeadPosition_Samples_Type is
   array (HeadPosition_Samples_Index) of HeadPosition_Samples_Values;

  procedure Reading_HeadPosition (H : out HeadPosition_Samples_Type);
  -- It reads the head position in axis x,y and returns
  -- the angle -90..+90 degrees

  ---------------------------------------------------------------------
  ------ DISTANCE -----------------------------------------------------

  type Distance_Samples_Type is new Natural range 0 .. 150;

  procedure Reading_Distance (L : out Distance_Samples_Type);
  -- It reads the distance with the previous vehicle: from 0m. to 150m.

  ---------------------------------------------------------------------
  ------ SPEED --------------------------------------------------------

  type Speed_Samples_Type is new Natural range 0 .. 200;

  procedure Reading_Speed (V : out Speed_Samples_Type);
  -- It reads the current vehicle speed: from 0m. to 200m.

  ---------------------------------------------------------------------
  ------ STEERING WHEEL -----------------------------------------------

  type Steering_Samples_Type is new Integer range -180 .. 180;

  procedure Reading_Steering (S : out Steering_Samples_Type);
  -- It reads the current position of the steering wheel: from -180 to 180

  ---------------------------------------------------------------------
  ------ OUTPUT devices interface
  ---------------------------------------------------------------------

  ---------------------------------------------------------------------
  procedure Display_Distance (D : Distance_Samples_Type);
  -- It displays the distance D

  ---------------------------------------------------------------------
  procedure Display_Speed (V : Speed_Samples_Type);
  -- It displays the speed V

  ---------------------------------------------------------------------
  procedure Display_Steering (S : Steering_Samples_Type);
  -- It displays the steering wheel position S

  --------------------------------------------------------------------
  procedure Display_HeadPosition_Sample (H : HeadPosition_Samples_Type);
  -- It displays the angle of the head position in both axis (x and y)

  ---------------------------------------------------------------------
  type Volume is new Integer range 1 .. 5;
  procedure Beep (v : Volume);
  -- It beeps with a volume "v"

  ---------------------------------------------------------------------
  type Light_States is (On, Off);
  procedure Light (E : Light_States);
  -- It turns ON/OFF the light

  ---------------------------------------------------------------------
  procedure Activate_Automatic_Driving;
  -- It activates the automatic driving system

  ---------------------------------------------------------------------
  procedure Activate_Brake;
  -- It activates the brake
end devices;
