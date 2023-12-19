with add;
with System;
with control; use control;

procedure main is
   pragma Priority (System.Priority'First);
   ret : Integer;
begin
   ret := Inicializar_dispositivos;

   ret := Poner_Led_Rojo (0);
   ret := Poner_Led_Verde (1);

   add.Background;
end main;
