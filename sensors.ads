package Sensors is
    task type Task_Cabeza_Type is
        pragma Priority (10);
    end Task_Cabeza_Type;
    task type Task_Distancia_Type is
        pragma Priority (30);
    end Task_Distancia_Type;
    task type Task_Volante_Type is
        pragma Priority (40);
    end Task_Volante_Type;
    task type Task_Modo_Type is
        pragma Priority (60);
    end Task_Modo_Type;
end Sensors;
