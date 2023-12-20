with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;
with Ada.Real_Time;       use Ada.Real_Time;

package control is
   type Tabla_sensores is array (1 .. 8) of Integer;
   --sensores: Tabla_sensores;

   function Inicializar_dispositivos return Integer;
   pragma Import (C, Inicializar_dispositivos, "Inicializar_dispositivos");

   procedure Leer_Sensores (sensores : out Tabla_sensores);
   pragma Import (C, Leer_Sensores, "Leer_Todos_Los_Sensores");

   function Leer_Sensor (pin : in Integer) return Integer;
   pragma Import (C, Leer_Sensor, "analogRead");

   function Leer_Pulsador return Integer;
   pragma Import (C, Leer_Pulsador, "Leer_Pulsador");

   function Poner_Led_Rojo (Led_Rojo : in Integer) return Integer;
   pragma Import (C, Poner_Led_Rojo, "Poner_Led_Rojo");

   function Poner_Led_Verde (Led_verde : in Integer) return Integer;
   pragma Import (C, Poner_Led_Verde, "Poner_Led_Verde");

   function Sensor_infrarrojos return Integer;
   pragma Import (C, Sensor_infrarrojos, "Sensor_infrarrojos");

   procedure Activar_trigger (Valor_Trig : in Integer);
   pragma Import (C, Activar_trigger, "activa_trigger");

   function Leer_echo return Integer;
   pragma Import (C, Leer_echo, "lee_echo");

   function Cerrar return Integer;
   pragma Import (C, Cerrar, "Cerrar_Dispositivos");

   function Girar_Motor (giro : in Integer) return Integer;
   pragma Import (C, Girar_Motor, "Mover_Servo");

   function Leer_X_Giroscopo return Integer;
   pragma Import (C, Leer_X_Giroscopo, "Leer_X_Giroscopo");

   function Leer_Y_Giroscopo return Integer;
   pragma Import (C, Leer_Y_Giroscopo, "Leer_Y_Giroscopo");

   function Esp_Int return Integer;
   pragma Import (C, Esp_Int, "EspInt");

end control;
