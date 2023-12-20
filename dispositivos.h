#include <errno.h>
#include <stdint.h>
#include <stdio.h>  // Used for printf() statements
#include <stdlib.h>
#include <string.h>
#include <wiringPi.h>  // Include WiringPi library!

#include <time.h>

// #define TRUE 1
// #define FALSE 0

int EspInt();

int Inicializar_dispositivos();

int analogRead(int pin);
int Leer_Todos_Los_Sensores(int valores[]);

int Poner_Led_Rojo(int Valor_led);
int Poner_Led_Verde(int Valor_led);

int Leer_Pulsador();

int Sensor_infrarrojos();

int activa_trigger(int Valor_trig);

int lee_echo();

int Mover_Servo(int posicion);

int Cerrar_Dispositivos();

int Leer_X_Giroscopo();

int Leer_Y_Giroscopo();

double get_x_rotation(double x, double y, double z);

double get_y_rotation(double x, double y, double z);

double dist(double a, double b);

int read_word_2c(int addr);