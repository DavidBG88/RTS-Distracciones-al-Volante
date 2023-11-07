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
