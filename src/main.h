/*
 * main.h
 *
 *  Created on: 15. 9. 2013
 *      Author: Tomas Bures <bures@d3s.mff.cuni.cz>
 */

#ifndef MAIN_H_
#define MAIN_H_

#include "stm32f4xx_hal.h"
#include "Button.h"

#include "LED.h"
#include "Button.h"
#include "UART.h"

extern Button infoButton;
extern LED greenLed;
extern LED redLed;
extern LED orangeLed;
extern LED blueLed;
extern PulseLED greenPulseLed;

static void SystemClock_Config(void);
static void Error_Handler(void);

#endif /* MAIN_H_ */
