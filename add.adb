with Ada.Text_IO; use Ada.Text_IO; -- compilador gnat
-- with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System;        use System;

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
-- | Cabeza    | 400         | 100           | 20       |
-- | Distancia | 300         | 300           | 40       |
-- | Volante   | 350         | 350           | 30       |
-- | Riesgos   | 150         | 150           | 50       |
-- | Display   | 1000        | 1000          | 10       |
-- | Modo      | X           | X             | 60       |

package body add is
   Task_Cabeza : Task_Cabeza_Type;
   Task_Distancia : Task_Display_Type;
   Task_Volante : Task_Volante_Type;
   Task_Riesgos : Task_Riesgos_Type;
   Task_Display : Task_Display_Type;
   Task_Modo : Task_Modo_Type;

   procedure Background is
   begin
      loop
         null;
      end loop;
   end Background;
begin
   Starting_Notice ("Programa Principal");

   Set_Priority(Task_Cabeza,    20);
   Set_Priority(Task_Distancia, 40);
   Set_Priority(Task_Volante,   30);
   Set_Priority(Task_Riesgos,   50);
   Set_Priority(Task_Display,   10);
   Set_Priority(Task_Modo,      60);

   Task_Cabeza;
   Task_Distancia;
   Task_Volante;
   Task_Riesgos;
   Task_Display;
   Task_Modo;

   Finishing_Notice ("Programa Principal");
end add;
