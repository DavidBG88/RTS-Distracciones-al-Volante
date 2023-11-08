package Actuators is
    task type Task_Riesgos_Type is
        pragma Priority (20);
    end Task_Riesgos_Type;
    task type Task_Display_Type is
        pragma Priority (50);
    end Task_Display_Type;
end Actuators;
