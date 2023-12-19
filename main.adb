with add;
with System;
with control;     use control;

procedure main is
   pragma Priority (System.Priority'First);
   device_init_status : Integer;
begin
   device_init_status := Inicializar_dispositivos();
   add.Background;
end main;
