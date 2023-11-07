with Ada.Text_IO;   use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

with devices; use devices;
with tools;   use tools;

with State; use State;

package body Sensors is
    -- Declaración de funciones auxiliares

    procedure Riesgo_Cabeza
       (Cabeza      : in     HeadPosition_Samples_Type;
        Volante     : in     Steering_Samples_Type; Prev_X_Risk : in Boolean;
        Prev_Y_Risk : in Boolean; X_Risk : out Boolean; Y_Risk : out Boolean;
        Risk        :    out Boolean);
    procedure Riesgo_Distancia
       (Velocidad : in     Speed_Samples_Type;
        Distancia : in     Distance_Samples_Type;
        Risk      :    out Sintoma_Distancia_Type);
    procedure Riesgo_Volante
       (Prev_Steering_Angle : in Steering_Samples_Type;
        Steering_Angle : in Steering_Samples_Type; Speed : Speed_Samples_Type;
        Prev_V_Risk : in Boolean; V_Risk : out Boolean; Risk : out Boolean);

    -- Tasks

    task body Cabeza is
        Task_Name   : constant String    := "Cabeza";
        Task_Period : constant Time_Span := Milliseconds (400);

        Next_Wake_Time : Time := Big_Bang + Task_Period;

        Head_Position  : HeadPosition_Samples_Type := (0, 0);
        Steering_Angle : Steering_Samples_Type     := 0;
        Prev_X_Risk    : Boolean                   := False;
        Prev_Y_Risk    : Boolean                   := False;
        X_Risk         : Boolean                   := False;
        Y_Risk         : Boolean                   := False;
        Head_Risk      : Boolean                   := False;
    begin
        loop
            Starting_Notice (Task_Name);

            Reading_HeadPosition (Head_Position);
            Reading_Steering (Steering_Angle);
            Riesgo_Cabeza
               (Head_Position, Steering_Angle, Prev_X_Risk, Prev_Y_Risk,
                X_Risk, Y_Risk, Head_Risk);
            Sintomas.Update_Cabeza (Head_Risk);
            Prev_X_Risk := X_Risk;
            Prev_Y_Risk := Y_Risk;

            Finishing_Notice (Task_Name);

            delay until Next_Wake_Time;
            Next_Wake_Time := Next_Wake_Time + Task_Period;
        end loop;
    end Cabeza;

    task body Distancia is
        Task_Name   : constant String    := "Distancia";
        Task_Period : constant Time_Span := Milliseconds (300);

        Next_Wake_Time : Time := Big_Bang + Task_Period;

        Distance_Risk : Sintoma_Distancia_Type := Segura;
        Distance      : Distance_Samples_Type  := 0;
        Speed         : Speed_Samples_Type     := 0;
    begin
        loop
            Starting_Notice (Task_Name);

            Reading_Speed (Speed);
            Reading_Distance (Distance);

            Riesgo_Distancia (Speed, Distance, Distance_Risk);
            Sintomas.Update_Distancia (Distance_Risk);
            Medidas.Update_Distancia (Distance);
            Medidas.Update_Velocidad (Speed);

            Finishing_Notice (Task_Name);

            delay until Next_Wake_Time;
            Next_Wake_Time := Next_Wake_Time + Task_Period;
        end loop;
    end Distancia;

    task body Volante is
        Task_Name   : constant String    := "Volante";
        Task_Period : constant Time_Span := Milliseconds (350);

        Next_Wake_Time : Time := Big_Bang + Task_Period;

        Risk                : Boolean               := False;
        V_Risk              : Boolean               := False;
        Prev_V_Risk         : Boolean               := False;
        Steering_Angle      : Steering_Samples_Type := 0;
        Prev_Steering_Angle : Steering_Samples_Type := 0;
        Speed               : Speed_Samples_Type    := 0;
    begin
        loop
            Starting_Notice (Task_Name);

            Reading_Steering (Steering_Angle);
            Riesgo_Volante
               (Prev_Steering_Angle, Steering_Angle, Speed, Prev_V_Risk,
                V_Risk, Risk);
            Prev_V_Risk         := V_Risk;
            Prev_Steering_Angle := Steering_Angle;
            Sintomas.Update_Volante (Risk);

            Finishing_Notice (Task_Name);

            delay until Next_Wake_Time;
            Next_Wake_Time := Next_Wake_Time + Task_Period;
        end loop;
    end Volante;

    task body Modo is
        Task_Name   : constant String    := "Modo";
        Task_Period : constant Time_Span := Milliseconds (100);

        Modo_Sistema : Modo_Sistema_Type := M1;
    begin
        loop
            Starting_Notice (Task_Name);

            Controlador_Modo.Esperar_Modo;

            Modo_Sistema := Controlador_Modo.Get_Modo_Sistema;

            if Modo_Sistema = M1 then
                if Sintomas.Get_Distancia /= Colision then
                    Controlador_Modo.Update_Modo_Sistema (M2);
                end if;
            elsif Modo_Sistema = M2 then
                if Sintomas.Get_Distancia /= Colision and
                   not Sintomas.Get_Cabeza
                then
                    Controlador_Modo.Update_Modo_Sistema (M3);
                end if;
            else
                Controlador_Modo.Update_Modo_Sistema (M1);
            end if;

            Finishing_Notice (Task_Name);
        end loop;
    end Modo;

    -- Definicion de funciones auxiliares

    procedure Riesgo_Cabeza
       (Cabeza      : in     HeadPosition_Samples_Type;
        Volante     : in     Steering_Samples_Type; Prev_X_Risk : in Boolean;
        Prev_Y_Risk : in Boolean; X_Risk : out Boolean; Y_Risk : out Boolean;
        Risk        :    out Boolean)
    is
        Current_X_Risk         : Boolean := False;
        Current_Y_Risk         : Boolean := False;
        Wheel_And_Head_Aligned : Boolean := False;
        Total_X_Risk           : Boolean := False;
        Total_Y_Risk           : Boolean := False;
    begin
        Current_X_Risk := abs (Cabeza (x)) > 30;
        Current_Y_Risk := abs (Cabeza (y)) > 30;

        Total_X_Risk := Current_X_Risk and Prev_X_Risk;

        Wheel_And_Head_Aligned :=
           Number_Sign (Integer (Volante)) =
           Number_Sign (Integer (Cabeza (y)));
        Total_Y_Risk           :=
           Current_Y_Risk and Prev_Y_Risk and abs (Volante) <= 30 and
           not Wheel_And_Head_Aligned;

        if Total_X_Risk or Total_Y_Risk then
            Risk := True;
        end if;

        X_Risk := Current_X_Risk;
        Y_Risk := Current_Y_Risk;
    end Riesgo_Cabeza;

    procedure Riesgo_Distancia
       (Velocidad : in     Speed_Samples_Type;
        Distancia : in     Distance_Samples_Type;
        Risk      :    out Sintoma_Distancia_Type)
    is
        Safety_Distance : Float := 0.0;
    begin
        Safety_Distance := (Float (Velocidad) / 10.0)**2;

        if Float (Distancia) < Safety_Distance / 3.0 then
            Risk := Colision;
        elsif Float (Distancia) < Safety_Distance / 2.0 then
            Risk := Imprudente;
        elsif Float (Distancia) < Safety_Distance then
            Risk := Insegura;
        else
            Risk := Segura;
        end if;
    end Riesgo_Distancia;

    procedure Riesgo_Volante
       (Prev_Steering_Angle : in Steering_Samples_Type;
        Steering_Angle : in Steering_Samples_Type; Speed : Speed_Samples_Type;
        Prev_V_Risk : in Boolean; V_Risk : out Boolean; Risk : out Boolean)
    is
        Angle_Diff : Integer := 0;
    begin
        Angle_Diff :=
           abs (Integer (Steering_Angle) - Integer (Prev_Steering_Angle));
        V_Risk     := Angle_Diff >= 20 and Speed > 40;
        Risk       := Prev_V_Risk and V_Risk;
    end Riesgo_Volante;
end Sensors;