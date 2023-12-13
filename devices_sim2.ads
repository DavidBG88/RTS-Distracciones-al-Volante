

with Ada.Real_Time; use Ada.Real_Time;

package devices is

    ---------------------------------------------------------------------
    ------ Access time for devices
    ---------------------------------------------------------------------
    WCET_Distance: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(12);
    WCET_Speed: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(7);
    WCET_HeadPosition: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);
    WCET_Steering: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(7);

    WCET_Eyes_Image: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(20);
    WCET_EEG: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(18);

    WCET_Display: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(15);
    WCET_Alarm: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Light: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Automatic_Driving: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Brake: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);


    ---------------------------------------------------------------------
    ------ INPUT devices interface
    ---------------------------------------------------------------------

    ---------------------------------------------------------------------
    ------ ELECTRODES --------------------------------------------------- 

    type Value_Electrode is new natural range 0..10;
    Number_Electrodes: constant integer := 10;

    type EEG_Samples_Index is new natural range 1..Number_Electrodes;
    type EEG_Samples_Type is array (EEG_Samples_Index) of Value_Electrode;


    procedure Reading_Sensors (L: out EEG_Samples_Type);
    -- It reads a sample of Electrode Sensors and returns a array of 10 values 

    ---------------------------------------------------------------------
    ------ EYES ---------------------------------------------------------

    type Eyes_Samples_Index is (left,right);
    type Eyes_Samples_Values is new natural range 0..100;
    type Eyes_Samples_Type is array (Eyes_Samples_Index) of Eyes_Samples_Values;

    procedure Reading_EyesImage (L: out Eyes_Samples_Type);
    -- It reads an image of the eyes, analyses the image and returns 
    --- the percentage of aperture (0..100) of every eye (left, right)

    ---------------------------------------------------------------------
    ------ HeadPosition -------------------------------------------------

    type HeadPosition_Samples_Index is (x,y);
    type HeadPosition_Samples_Values is new integer range -90..+90;
    type HeadPosition_Samples_Type is array (HeadPosition_Samples_Index) 
                                         of HeadPosition_Samples_Values;

    procedure Reading_HeadPosition (H: out HeadPosition_Samples_Type);
    -- It reads the head position in axis x,y and returns 
    -- the angle -90..+90 degrees 

    ---------------------------------------------------------------------
    ------ DISTANCE -----------------------------------------------------

    type Distance_Samples_Type is new natural range 0..150;

    procedure Reading_Distance (L: out Distance_Samples_Type);
    -- It reads the distance with the previous vehicle: from 0m. to 150m. 

    ---------------------------------------------------------------------
    ------ SPEED --------------------------------------------------------

    type Speed_Samples_Type is new natural range 0..200;

    procedure Reading_Speed (V: out Speed_Samples_Type);
    -- It reads the current vehicle speed: from 0m. to 200m. 

    ---------------------------------------------------------------------
    ------ STEERING WHEEL -----------------------------------------------

    type Steering_Samples_Type is new integer range -180..180;

    procedure Reading_Steering (S: out Steering_Samples_Type);
    -- It reads the current position of the steering wheel: from -180 to 180 

    ---------------------------------------------------------------------
    ------ OUTPUT devices interface  
    ---------------------------------------------------------------------

    type Values_Pulse_Rate is new float range 20.0..300.0;

    procedure Display_Pulse_Rate (P: Values_Pulse_Rate);
    -- It displays the pulse rate P

    ---------------------------------------------------------------------
    procedure Display_Electrodes_Sample (R: EEG_Samples_Type);
    -- It displays the 10 values of the electrodes sample 

    --------------------------------------------------------------------
    procedure Display_Eyes_Sample (R: Eyes_Samples_Type);
    -- It displays the values of eyes aperture (left and right) 

    ---------------------------------------------------------------------
    procedure Display_Distance (D: Distance_Samples_Type);
    -- It displays the distance D

    ---------------------------------------------------------------------
    procedure Display_Speed (V: Speed_Samples_Type);
    -- It displays the speed V

    ---------------------------------------------------------------------
    procedure Display_Steering (S: Steering_Samples_Type);
    -- It displays the steering wheel position S

    --------------------------------------------------------------------
    procedure Display_HeadPosition_Sample (H: HeadPosition_Samples_Type);
    -- It displays the angle of the head position in both axis (x and y) 

    ---------------------------------------------------------------------
    procedure Display_Cronometro (Origen: Ada.Real_Time.Time; Hora: Ada.Real_Time.Time);
    -- It displays a chronometer 

    ---------------------------------------------------------------------
    Type Volume is new integer range 1..5; 
    procedure Beep (v: Volume); 
    -- It beeps with a volume "v" 

    ---------------------------------------------------------------------
    type Light_States is (On, Off);
    procedure Light (E: Light_States);
    -- It turns ON/OFF the light 

    ---------------------------------------------------------------------
    procedure Activate_Automatic_Driving;
    -- It activates the automatic driving system 
	
	---------------------------------------------------------------------
	procedure Activate_Brake;
	-- It activates the brake 


    ---------------------------------------------------------------------
    ------ SCENARIO  
    ---------------------------------------------------------------------

    -- Conductor inclina demasiado la cabeza con velocidad superior a 70

    ---------------------------------------------------------------------
    ------ SPEED --------------------------------------------------------

    cantidad_datos_Velocidad: constant := 100;
    type Indice_Secuencia_Velocidad is mod cantidad_datos_Velocidad;
    type tipo_Secuencia_Velocidad is array (Indice_Secuencia_Velocidad) of Speed_Samples_Type;

    Speed_Simulation: tipo_Secuencia_Velocidad := (others => 80);

    ---------------------------------------------------------------------
    ------ DISTANCE -----------------------------------------------------
    cantidad_datos_Distancia: constant := 100;
    type Indice_Secuencia_Distancia is mod cantidad_datos_Distancia;
    type tipo_Secuencia_Distancia is array (Indice_Secuencia_Distancia) of Distance_Samples_Type;

    Distance_Simulation: tipo_Secuencia_Distancia := (others => 100);

    ---------------------------------------------------------------------
    ------ HEAD POSITION ------------------------------------------------

    cantidad_datos_HeadPosition: constant := 100;
    type Indice_Secuencia_HeadPosition is mod cantidad_datos_HeadPosition;
    type tipo_Secuencia_HeadPosition is array (Indice_Secuencia_HeadPosition) 
                                             of HeadPosition_Samples_Type;

    HeadPosition_Simulation: tipo_Secuencia_HeadPosition :=
                ((+01,+03),(+01,+03),(+02,+01),(+03,+00),(+01,-03),  -- 1 muestra cada 100ms.
                 (+01,+03),(-01,+03),(-02,+01),(+03,+00),(+01,-03),  --1s.
 
                 (+01,+03),(+01,+03),(+02,+01),(+03,+00),(+01,-03),  
                 (+01,+03),(-01,+03),(-02,+01),(+03,+00),(+01,-03),  --2s.
                
                 others => (0, 50));

    ---------------------------------------------------------------------
    ------ STEERING WHEEL -----------------------------------------------

    cantidad_datos_Volante: constant := 100;
    type Indice_Secuencia_Volante is mod cantidad_datos_Volante;
    type tipo_Secuencia_Volante is array (Indice_Secuencia_Volante) of Steering_Samples_Type;

    Steering_Simulation: tipo_Secuencia_Volante := (others => 0);

    ---------------------------------------------------------------------
    ------ EYESIMAGE ----------------------------------------------------

    cantidad_datos_EyesImage: constant := 100;
    type Indice_Secuencia_EyesImage is mod cantidad_datos_EyesImage;
    type tipo_Secuencia_EyesImage is array (Indice_Secuencia_EyesImage) of Eyes_Samples_Type;

    Eyes_Simulation: tipo_Secuencia_EyesImage :=
                ((85,85),(70,70),(85,85),(85,85),(05,05),  -- 1 muestra cada 100ms.
                 (05,05),(85,85),(20,20),(85,85),(85,85),  --1s.
 
                 (70,70),(60,60),(60,60),(40,40),(40,40),
                 (40,40),(40,40),(40,40),(40,40),(30,30),  --2s.

                 (30,30),(30,30),(40,40),(40,40),(40,40),
                 (50,50),(50,50),(50,50),(50,50),(50,50),  --3s.

                 (60,60),(60,60),(50,50),(40,40),(40,40),
                 (50,50),(50,50),(50,50),(50,50),(50,50),  --4s.

                 (30,30),(30,30),(40,40),(40,40),(40,40),
                 (50,50),(50,50),(50,50),(50,50),(50,50),  --5s.
                  
                 (20,20),(20,20),(20,20),(25,25),(25,25),
                 (20,20),(20,20),(20,20),(15,15),(15,15),  --6s.
 
                 (10,10),(10,10),(10,10),(10,10),(10,40),
                 ( 0, 0),( 0, 0),( 5, 5),( 5, 5),( 5, 5),  --7s.

                 ( 0, 0),( 0, 0),( 0, 0),( 0, 0),( 0, 0),
                 ( 0, 0),( 0, 0),( 0, 0),( 0, 0),( 0, 0),  --8s.

                 ( 0, 0),( 0, 0),( 0, 0),( 0, 0),( 0, 0),
                 ( 0, 0),( 0, 0),( 0, 0),( 0, 0),( 0, 0),  --9s.

                 ( 0, 0),( 0, 0),( 0, 0),( 0, 0),( 0, 0),
                 ( 0, 0),( 0, 0),( 0, 0),( 0, 0),( 0, 0) );  --10s.

    ---------------------------------------------------------------------
    ------ EEG ----------------------------------------------------------

    cantidad_datos_Sensores: constant := 100;
    type Indice_Secuencia_Sensores is mod cantidad_datos_Sensores;
    type tipo_Secuencia_Sensores is array (Indice_Secuencia_Sensores) of EEG_Samples_Type;

    EEG_Simulation: tipo_Secuencia_Sensores := 
      ((7,7,7,7,7,7,7,7,7,7),(7,7,7,7,7,7,7,7,7,7),  -- 1 muestra cada 100ms.
       (7,7,7,7,7,7,7,7,7,7),(7,7,7,7,7,7,7,7,7,7),
       (7,7,7,7,7,7,7,7,7,7),(8,8,8,8,8,8,8,8,8,8),
       (8,8,8,8,8,8,8,8,8,8),(8,8,8,8,8,8,8,8,8,8),
       (8,8,8,8,8,8,8,8,8,8),(8,8,8,8,8,8,8,8,8,8),   --1s.

       (4,4,4,4,4,4,4,4,4,4),(4,4,4,4,4,4,4,4,4,4),
       (4,4,4,4,4,4,4,4,4,4),(5,5,5,5,5,5,5,5,5,5),
       (5,5,5,5,5,5,5,5,5,5),(6,6,6,6,6,6,6,6,6,6),
       (6,6,6,6,6,6,6,6,6,6),(6,6,6,6,6,6,6,6,6,6),
       (6,6,6,6,6,6,6,6,6,6),(6,6,6,6,6,6,6,6,6,6),   --2s.

       (1,1,1,1,1,1,1,1,1,1),(1,1,1,1,1,1,1,1,1,1),
       (1,1,1,1,1,1,1,1,1,1),(2,2,2,2,2,2,2,2,2,2),
       (2,2,2,2,2,2,2,2,2,2),(2,2,2,2,2,2,2,2,2,2),
       (2,2,2,2,2,2,2,2,2,2),(3,3,3,3,3,3,3,3,3,3),
       (3,3,3,3,3,3,3,3,3,3),(3,3,3,3,3,3,3,3,3,3),   --3s.

       (1,1,1,1,1,1,1,1,1,1),(1,1,1,1,1,1,1,1,1,1),
       (1,1,1,1,1,1,1,1,1,1),(2,2,2,2,2,2,2,2,2,2),
       (2,2,2,2,2,2,2,2,2,2),(2,2,2,2,2,2,2,2,2,2),
       (2,2,2,2,2,2,2,2,2,2),(3,3,3,3,3,3,3,3,3,3),
       (3,3,3,3,3,3,3,3,3,3),(3,3,3,3,3,3,3,3,3,3),   --4s.

       (4,4,4,4,4,4,4,4,4,4),(4,4,4,4,4,4,4,4,4,4),
       (4,4,4,4,4,4,4,4,4,4),(5,5,5,5,5,5,5,5,5,5),
       (5,5,5,5,5,5,5,5,5,5),(7,7,7,7,7,7,7,7,7,7),
       (7,7,7,7,7,7,7,7,7,7),(7,7,7,7,7,7,7,7,7,7),
       (7,7,7,7,7,7,7,7,7,7),(7,7,7,7,7,7,7,7,7,7),   --5s.

       (7,7,7,7,7,7,7,7,7,7),(7,7,7,7,7,7,7,7,7,7),
       (7,7,7,7,7,7,7,7,7,7),(7,7,7,7,7,7,7,7,7,7),
       (7,7,7,7,7,7,7,7,7,7),(8,8,8,8,8,8,8,8,8,8),
       (8,8,8,8,8,8,8,8,8,8),(8,8,8,8,8,8,8,8,8,8),
       (8,8,8,8,8,8,8,8,8,8),(8,8,8,8,8,8,8,8,8,8),   --6s.

       (4,4,4,4,4,4,4,4,4,4),(4,4,4,4,4,4,4,4,4,4),
       (4,4,4,4,4,4,4,4,4,4),(5,5,5,5,5,5,5,5,5,5),
       (5,5,5,5,5,5,5,5,5,5),(6,6,6,6,6,6,6,6,6,6),
       (6,6,6,6,6,6,6,6,6,6),(6,6,6,6,6,6,6,6,6,6),
       (6,6,6,6,6,6,6,6,6,6),(6,6,6,6,6,6,6,6,6,6),   --7s.

       (1,1,1,1,1,1,1,1,1,1),(1,1,1,1,1,1,1,1,1,1),
       (1,1,1,1,1,1,1,1,1,1),(2,2,2,2,2,2,2,2,2,2),
       (2,2,2,2,2,2,2,2,2,2),(2,2,2,2,2,2,2,2,2,2),
       (2,2,2,2,2,2,2,2,2,2),(3,3,3,3,3,3,3,3,3,3),
       (3,3,3,3,3,3,3,3,3,3),(3,3,3,3,3,3,3,3,3,3),   --8s.

       (1,1,1,1,1,1,1,1,1,1),(1,1,1,1,1,1,1,1,1,1),
       (1,1,1,1,1,1,1,1,1,1),(2,2,2,2,2,2,2,2,2,2),
       (2,2,2,2,2,2,2,2,2,2),(2,2,2,2,2,2,2,2,2,2),
       (2,2,2,2,2,2,2,2,2,2),(3,3,3,3,3,3,3,3,3,3),
       (3,3,3,3,3,3,3,3,3,3),(3,3,3,3,3,3,3,3,3,3),   --9s.

       (4,4,4,4,4,4,4,4,4,4),(4,4,4,4,4,4,4,4,4,4),
       (4,4,4,4,4,4,4,4,4,4),(5,5,5,5,5,5,5,5,5,5),
       (5,5,5,5,5,5,5,5,5,5),(7,7,7,7,7,7,7,7,7,7),
       (7,7,7,7,7,7,7,7,7,7),(7,7,7,7,7,7,7,7,7,7),
       (7,7,7,7,7,7,7,7,7,7),(7,7,7,7,7,7,7,7,7,7) );   --10s.

end devices;



