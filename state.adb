package body State is
    protected body Sintomas is
        procedure Update_Cabeza (Risk : Boolean) is
        begin
            Riesgo_Cabeza := Risk;
        end Update_Cabeza;

        procedure Update_Distancia (Risk : Sintoma_Distancia_Type) is
            Speed           : Speed_Samples_Type    := 0;
            Distance        : Distance_Samples_Type := 0;
            Safety_Distance : Float                 := 0.0;
        begin
            Riesgo_Distancia := Risk;
        end Update_Distancia;

        procedure Update_Volante (Risk : Boolean) is
        begin
            Riesgo_Volante := Risk;
        end Update_Volante;

        function Get_Cabeza return Boolean is
        begin
            return Riesgo_Cabeza;
        end Get_Cabeza;

        function Get_Distancia return Sintoma_Distancia_Type is
        begin
            return Riesgo_Distancia;
        end Get_Distancia;

        function Get_Volante return Boolean is
        begin
            return Riesgo_Volante;
        end Get_Volante;
    end Sintomas;

    protected body Medidas is
        procedure Update_Distancia (Distancia : in Distance_Samples_Type) is
        begin
            Medidas.Distancia := Distancia;
        end Update_Distancia;

        procedure Update_Velocidad (Velocidad : in Speed_Samples_Type) is
        begin
            Medidas.Velocidad := Velocidad;
        end Update_Velocidad;

        function Get_Distancia return Distance_Samples_Type is
        begin
            return Medidas.Distancia;
        end Get_Distancia;

        function Get_Velocidad return Speed_Samples_Type is
        begin
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
            Modo_Sistema := Modo;
        end Update_Modo_Sistema;

        function Get_Modo_Sistema return Modo_Sistema_Type is
        begin
            return Modo_Sistema;
        end Get_Modo_Sistema;
    end Controlador_Modo;

end State;
