#include "dispositivos.h"

#include <errno.h>
#include <stdint.h>
#include <stdio.h>  // Used for printf() statements
#include <stdlib.h>
#include <string.h>
#include <wiringPi.h>  // Include WiringPi library!

// #include <softPwm.h>

#include <time.h>

// Pin number declarations. We're using the Broadcom chip pin numbers.

#define PIN_trigger 2  // GPIO_P1_13 - out - trigger
#define PIN_echo 7     // GPIO_P1_07 - in - echo

#define PIN_celula 6  // GPIO_P1_22 - in - infrarrojos

#define PIN_libre 0  // GPIO_P1_11 - in

#define PIN_pulsador 3  // GPIO_P1_15 - in - pulsador

#define PIN_led_1 4  // GPIO_P1_16 - out - luz 1
#define PIN_led_2 5  // GPIO_P1_18 - out - luz 2

#define PIN_pwm 1  // GPIO_P1_12

// #define TRUE 1
// #define FALSE 0

static pthread_mutex_t mymutex2;

const int pwmValue = 75;  // Use this to set an LED brightness

void RTI() {
    pthread_mutex_unlock(&mymutex2);
    printf("\n ----/----> \n");
}

int Inicializar_dispositivos() {

    system("gpio load spi");

    pwmSetMode(PWM_MODE_MS);  // PWM_MODEBAL or PWM_MODE_MS
    // softPwmCreate (PIN_pwm, 0, 100);

    wiringPiSetup();  // Initialize wiringPi -- using Broadcom? pin numbers

    if (wiringPiSPISetup(0, 1000000) < 0)  // Configuring conexion to 0.5 MHz
    {
        fprintf(stderr, "Unable to open SPI device 0: %s\n", strerror(errno));
        exit(1);
    }

    // Configurar el modo de los pines GPIO
    pinMode(PIN_led_1, OUTPUT);  // 4 luz 1
    pinMode(PIN_led_2, OUTPUT);  // 5 luz 2

    pinMode(PIN_pulsador, INPUT);  // 3 pulsador

    pinMode(PIN_celula, INPUT);  // 6 infrarrojo

    pinMode(PIN_echo, INPUT);      // 7 echo de ultrasonidos
    pinMode(PIN_trigger, OUTPUT);  // 2 trigger de ultrasonidos

    pinMode(PIN_libre, INPUT);  // 0

    pinMode(PIN_pwm, PWM_OUTPUT);  // 1 Set PWM LED as PWM output

    printf("---- Devices configured \n");

    //======================================================================
    // INTERRUPCION
    if (wiringPiISR(PIN_pulsador, INT_EDGE_RISING, &RTI) < 0) {
        fprintf(stderr, "Unable to setup ISR: %s\n", strerror(errno));
        exit(1);
    }
    /*
      if (wiringPiISR (PIN_pulsador, INT_EDGE_FALLING, &RTI) < 0)
      {
       fprintf (stderr, "Unable to setup ISR: %s\n", strerror (errno)) ;
       exit(1) ;
      }
  */
    printf("-- Interrupt ready \n");
}

int analogRead(int pin) {
    int ADC = -1;
    if ((pin >= 0) && (pin <= 7)) {
        int ce = 0;
        unsigned char ByteSPI[7];

        // loading data
        ByteSPI[0] = 0b01;                  // The last bit is the start signal
        ByteSPI[1] = (0x80) | (pin << 4);   // 4 bits to configure the mode
        ByteSPI[2] = 0;                     // 8 bit to write the result of analog reading
        wiringPiSPIDataRW(ce, ByteSPI, 3);  // we send the order
        usleep(20);                         // waiting 20 microsecpnds

        ADC = ((ByteSPI[1] & 0x03) << 8) | ByteSPI[2];  // we take the data
    }
    return (ADC);
}

int Leer_Todos_Los_Sensores(int valores[]) {
    int i, analog;

    printf("---- ");

    for (i = 0; i < 8; i++) {
        analog = analogRead(i);
        valores[i] = analog;
        printf("ADC%d:%d  ", i, analog);
        delay(100);
    }
    printf("\n");
    return (0);
}

int Poner_Led_Rojo(int Valor_led) {
    digitalWrite(PIN_led_1, Valor_led);
}

int Poner_Led_Verde(int Valor_led) {
    digitalWrite(PIN_led_2, Valor_led);
}

int Leer_Pulsador() {
    int valor;
    valor = digitalRead(PIN_pulsador);
    if (valor)
        printf("---- Pulsador ON \n");
    else
        printf("---- Pulsador OFF \n");
    return (valor);
}

int Sensor_infrarrojos() {
    int valor;
    valor = digitalRead(PIN_celula);
    if (valor)
        printf("---- Infrarrojos ON \n");
    else
        printf("---- Infrarrojos OFF\n");
    return (valor);
}

int activa_trigger(int Valor_trig) {
    digitalWrite(PIN_trigger, Valor_trig);
};

int lee_echo() {
    int valor;
    valor = digitalRead(PIN_echo);
    if (valor)
        printf("---- Echo ON  \n");
    else
        printf("---- Echo OFF \n");
    return (valor);
};

int Mover_Servo(int posicion) {
    printf("Girar Servo %d \n", posicion);
    pwmWrite(1, posicion);
    // softPwmWrite (PIN_pwm,posicion);
    return (0);
}

int Cerrar_Dispositivos() {
    printf("---- Se cierran los dispositivos \n");
}

int fd;
void Inicializar_dispositivos() {
    ..........fd = wiringPiI2CSetup(0x68);
    wiringPiI2CWriteReg8(fd, 0x6B, 0x00);  //disable sleep mode
}

double dist(double a, double b) {
    return sqrt((a * a) + (b * b));
}

int read_word_2c(int addr) {
    int val;
    val = wiringPiI2CReadReg8(fd, addr);
    val = val << 8;
    val += wiringPiI2CReadReg8(fd, addr + 1);
    if (val >= 0x8000)
        val = -(65536 - val);

    return val;
}

double get_y_rotation(double x, double y, double z) {
    double radians;
    radians = atan2(x, dist(y, z));
    return -(radians * (180.0 / M_PI));
}

double get_x_rotation(double x, double y, double z) {
    double radians;
    radians = atan2(y, dist(x, z));
    return (radians * (180.0 / M_PI));
}

int Leer_X_Giroscopo() {

    int acclX, acclY, acclZ;
    double acclX_scaled, acclY_scaled, acclZ_scaled;
    acclX = read_word_2c(0x3B);
    acclY = read_word_2c(0x3D);
    acclZ = read_word_2c(0x3F);

    acclX_scaled = acclX / 16384.0;
    acclY_scaled = acclY / 16384.0;
    acclZ_scaled = acclZ / 16384.0;

    return get_x_rotation(acclX_scaled, acclY_scaled, acclZ_scaled);
}

int Leer_Y_Giroscopo() {

    int acclX, acclY, acclZ;
    double acclX_scaled, acclY_scaled, acclZ_scaled;
    acclX = read_word_2c(0x3B);
    acclY = read_word_2c(0x3D);
    acclZ = read_word_2c(0x3F);

    acclX_scaled = acclX / 16384.0;
    acclY_scaled = acclY / 16384.0;
    acclZ_scaled = acclZ / 16384.0;

    return get_y_rotation(acclX_scaled, acclY_scaled, acclZ_scaled);
}