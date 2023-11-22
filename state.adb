with Ada.Real_Time; use Ada.Real_Time;

package body State is
    protected body Sintomas is
        procedure Update_Cabeza (Risk : Boolean) is
        begin
            Execution_Time (Milliseconds(4));
            Riesgo_Cabeza := Risk;
        end Update_Cabeza;

        procedure Update_Distancia (Risk : Sintoma_Distancia_Type) is
        begin
            Execution_Time (Milliseconds(4));
            Riesgo_Distancia := Risk;
        end Update_Distancia;

        procedure Update_Volante (Risk : Boolean) is
        begin
            Execution_Time (Milliseconds(4));
            Riesgo_Volante := Risk;
        end Update_Volante;

        function Get_Cabeza return Boolean is
        begin
            Execution_Time (Milliseconds(2));
            return Riesgo_Cabeza;
        end Get_Cabeza;

        function Get_Distancia return Sintoma_Distancia_Type is
        begin
            Execution_Time (Milliseconds(2));
            return Riesgo_Distancia;
        end Get_Distancia;

        function Get_Volante return Boolean is
        begin
            Execution_Time (Milliseconds(2));
            return Riesgo_Volante;
        end Get_Volante;
    end Sintomas;

    protected body Medidas is
        procedure Update_Distancia (Distancia : in Distance_Samples_Type) is
        begin
            Execution_Time (Milliseconds(4));
            Medidas.Distancia := Distancia;
        end Update_Distancia;

        procedure Update_Velocidad (Velocidad : in Speed_Samples_Type) is
        begin
            Execution_Time (Milliseconds(4));
            Medidas.Velocidad := Velocidad;
        end Update_Velocidad;

        function Get_Distancia return Distance_Samples_Type is
        begin
            Execution_Time (Milliseconds(2));
            return Medidas.Distancia;
        end Get_Distancia;

        function Get_Velocidad return Speed_Samples_Type is
        begin
            Execution_Time (Milliseconds(2));
            return Medidas.Velocidad;
        end Get_Velocidad;
    end Medidas;

    protected body Controlador_Modo is
        procedure Interrupcion is
        begin
            Llamada_Pendiente := True;
        end Interrupcion;

        entry Esperar_Modo when Llamada_Pendiente is
        begin
            Llamada_Pendiente := False;
        end Esperar_Modo;

        procedure Update_Modo_Sistema (Modo : in Modo_Sistema_Type) is
        begin
            Execution_Time (Milliseconds(4));
            Modo_Sistema := Modo;
        end Update_Modo_Sistema;

        function Get_Modo_Sistema return Modo_Sistema_Type is
        begin
            Execution_Time (Milliseconds(2));
            return Modo_Sistema;
        end Get_Modo_Sistema;
    end Controlador_Modo;

end State;
