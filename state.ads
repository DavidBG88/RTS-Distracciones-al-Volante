with Ada.Interrupts.Names;

with devices;         use devices;
with pulse_interrupt; use pulse_interrupt;
with tools;           use tools;

package State is
    type Sintoma_Distancia_Type is (Segura, Insegura, Imprudente, Colision);
    type Modo_Sistema_Type is (M1, M2, M3);

    protected Sintomas is
        -- pragma Priority (6);
        pragma Priority (7);

        procedure Update_Cabeza (Risk : Boolean);
        procedure Update_Distancia (Risk : Sintoma_Distancia_Type);
        procedure Update_Volante (Risk : Boolean);

        function Get_Cabeza return Boolean;
        function Get_Distancia return Sintoma_Distancia_Type;
        function Get_Volante return Boolean;
    private
        Riesgo_Cabeza    : Boolean                := False;
        Riesgo_Distancia : Sintoma_Distancia_Type := Segura;
        Riesgo_Volante   : Boolean                := False;
    end Sintomas;

    protected Medidas is
        -- pragma Priority (4);
        pragma Priority (7);

        procedure Update_Distancia (Distancia : in Distance_Samples_Type);
        procedure Update_Velocidad (Velocidad : in Speed_Samples_Type);

        function Get_Distancia return Distance_Samples_Type;
        function Get_Velocidad return Speed_Samples_Type;
    private
        Distancia : Distance_Samples_Type := 0;
        Velocidad : Speed_Samples_Type    := 0;
    end Medidas;

    protected Controlador_Modo is
        pragma Priority (Priority_Of_External_Interrupts_2);

        procedure Interrupcion;
        pragma Attach_Handler
           (Interrupcion, Ada.Interrupts.Names.External_Interrupt_2);

        entry Esperar_Modo;

        procedure Update_Modo_Sistema (Modo : in Modo_Sistema_Type);
        function Get_Modo_Sistema return Modo_Sistema_Type;
    private
        Llamada_Pendiente : Boolean           := False;
        Modo_Sistema      : Modo_Sistema_Type := M1;
    end Controlador_Modo;
end State;
