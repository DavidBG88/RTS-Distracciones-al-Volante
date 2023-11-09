package Actuators is
    task type Task_Riesgos_Type is
        pragma Priority (4);
    end Task_Riesgos_Type;
    task type Task_Display_Type is
        pragma Priority (1);
    end Task_Display_Type;
end Actuators;
