package Sensors is
    task Cabeza is
        pragma Priority (20);
    end Cabeza;
    task Distancia is
        pragma Priority (40);
    end Distancia;
    task Volante is
        pragma Priority (30);
    end Volante;
    task Modo is
        pragma Priority (60);
    end Modo;
end Sensors;
