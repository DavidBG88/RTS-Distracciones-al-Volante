with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time;        use Ada.Real_Time;
with System;               use System;

with tools;   use tools;
with devices; use devices;

-- Packages needed to generate pulse interrupts
with Ada.Interrupts.Names;
with pulse_interrupt; use pulse_interrupt;

-- Import tasks packages
with Sensors;   use Sensors;
with Actuators; use Actuators;
with State;     use State;

----------------------------------------------------------------------
------------- tasks info
----------------------------------------------------------------------

-- | Task      | Period (ms) | Deadline (ms) | Priority |
-- | --------- | ----------- | ------------- | -------- |
-- | Cabeza    | 400         | 100           | 5        |
-- | Distancia | 300         | 300           | 3        |
-- | Volante   | 350         | 350           | 2        |
-- | Riesgos   | 150         | 150           | 4        |
-- | Display   | 1000        | 1000          | 1        |
-- | Modo      | 100         | 100           | 6        |

package body add is
   Task_Cabeza    : Task_Cabeza_Type;
   Task_Distancia : Task_Distancia_Type;
   Task_Volante   : Task_Volante_Type;
   Task_Riesgos   : Task_Riesgos_Type;
   Task_Display   : Task_Display_Type;
   Task_Modo      : Task_Modo_Type;

   procedure Background is
   begin
      loop
         null;
      end loop;
   end Background;
begin
   Starting_Notice ("Programa Principal");
   Finishing_Notice ("Programa Principal");
end add;
