with Ada.Text_IO;   use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

with tools;   use tools;
with devices; use devices;

with State; use State;

package body Actuators is
    task body Task_Riesgos_Type is
        Task_Name   : constant String    := "Riesgos";
        Task_Period : constant Time_Span := Milliseconds (150);

        Next_Wake_Time : Time := Big_Bang + Task_Period;

        Sintoma_Distancia : Sintoma_Distancia_Type := Segura;
        Sintoma_Volante   : Boolean                := False;
        Sintoma_Cabeza    : Boolean                := False;
        Medida_Velocidad  : Speed_Samples_Type     := 0;

        Beep_Intensity : Volume       := 1;
        Beep_Value     : Boolean      := False;
        Brake_Value    : Boolean      := False;
        Light_Value    : Light_States := Off;

        Modo_Sistema : Modo_Sistema_Type := M1;
    begin
        loop
            Starting_Notice (Task_Name);

            -- Store protected objects state

            Modo_Sistema := Controlador_Modo.Get_Modo_Sistema;

            if Modo_Sistema = M1 or Modo_Sistema = M2 then
                Sintoma_Distancia := Sintomas.Get_Distancia;
                Sintoma_Volante   := Sintomas.Get_Volante;
                Sintoma_Cabeza    := Sintomas.Get_Cabeza;
                Medida_Velocidad  := Medidas.Get_Velocidad;

                -- Update actuator values

                if Sintoma_Distancia = Colision and Sintoma_Cabeza then
                    Beep_Intensity := Volume'Max (5, Beep_Intensity);
                    Beep_Value     := True;
                    Brake_Value    := True;
                end if;

                if Modo_Sistema = M1 then
                    if Sintoma_Distancia = Insegura then
                        Light_Value := On;
                    elsif Sintoma_Distancia = Imprudente then
                        Beep_Intensity := Volume'Max (4, Beep_Intensity);
                        Beep_Value     := True;
                        Light_Value    := On;
                    end if;
                end if;

                if Sintoma_Cabeza then
                    if Medida_Velocidad > 70 then
                        Beep_Intensity := Volume'Max (3, Beep_Intensity);
                    else
                        Beep_Intensity := Volume'Max (2, Beep_Intensity);
                    end if;
                end if;

                if Sintoma_Volante and not Sintoma_Cabeza and
                   Sintoma_Distancia = Segura
                then
                    Beep_Intensity := 1;
                end if;

                -- Update actuators

                Light (Light_Value);
                if Beep_Value then
                    Beep (Beep_Intensity);
                end if;
                if Brake_Value then
                    Activate_Brake;
                end if;
            end if;

            Finishing_Notice (Task_Name);

            delay until Next_Wake_Time;
            Next_Wake_Time := Next_Wake_Time + Task_Period;
        end loop;
    end Task_Riesgos_Type;

    task body Task_Display_Type is
        Task_Name   : constant String    := "Display";
        Task_Period : constant Time_Span := Milliseconds (1_000);

        Next_Wake_Time : Time := Big_Bang + Task_Period;
    begin
        loop
            Starting_Notice (Task_Name);

            New_Line;
            New_Line;

            Put_Line
               ("Distancia: " &
                Distance_Samples_Type'Image (Medidas.Get_Distancia));
            Put_Line
               ("Velocidad: " &
                Speed_Samples_Type'Image (Medidas.Get_Velocidad));

            Put_Line ("Sintomas: ");
            if Sintomas.Get_Cabeza then
                Put_Line ("    Cabeza:    RIESGO");
            else
                Put_Line ("    Cabeza:    OK");
            end if;

            Put_Line
               ("    Distancia: " &
                Sintoma_Distancia_Type'Image (Sintomas.Get_Distancia));
            if Sintomas.Get_Volante then
                Put_Line ("    Volante:   RIESGO");
            else
                Put_Line ("    Volante:   OK");
            end if;

            Finishing_Notice (Task_Name);

            delay until Next_Wake_Time;
            Next_Wake_Time := Next_Wake_Time + Task_Period;
        end loop;
    end Task_Display_Type;
end Actuators;
