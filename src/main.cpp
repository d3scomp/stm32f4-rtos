#include "main.h"
#include "FreeRTOS.h"
#include "task.h"

#include <cstdio>

extern "C" {
	int _write(int file, char * ptr, int len);
}
void initUART();

uint32_t mainCycles = 0;

void blinkTask(void* p) {
	const TickType_t period = 1000 / portTICK_PERIOD_MS;

	TickType_t lastWakeTime = xTaskGetTickCount();
	for(;;) {
		greenPulseLed.pulse();
		mainCycles++;

		// Wait for the next cycle.
		vTaskDelayUntil(&lastWakeTime, period);
	}

	vTaskDelete(NULL);
}


struct Properties {
		GPIO_TypeDef* gpio;
		USART_TypeDef* usart;
		uint32_t pinTX, pinRX;
		uint16_t pinSourceTX, pinSourceRX;
		void (*clkUSARTCmdFun)(uint32_t periph, FunctionalState newState);
		uint32_t clkGPIO, clkUSART;
		uint8_t afConfig;
		uint8_t irqn;
		uint32_t baudRate;
	};

// Serial console
Properties uart2Props {
GPIOA, USART2,
GPIO_Pin_2, GPIO_Pin_3, GPIO_PinSource2, GPIO_PinSource3, RCC_APB1PeriphClockCmd, RCC_AHB1Periph_GPIOA,
RCC_APB1Periph_USART2, GPIO_AF_USART2, USART2_IRQn, 921600 };


LED::Properties greenLedProps {
	GPIOD, GPIO_Pin_12, RCC_AHB1Periph_GPIOD
};
LED::Properties redLedProps {
	GPIOD, GPIO_Pin_14, RCC_AHB1Periph_GPIOD
};
LED::Properties orangeLedProps {
	GPIOD, GPIO_Pin_13, RCC_AHB1Periph_GPIOD
};
LED::Properties blueLedProps {
	GPIOD, GPIO_Pin_15, RCC_AHB1Periph_GPIOD
};
LED greenLed(greenLedProps);
LED redLed(redLedProps);
LED blueLed(blueLedProps);
LED orangeLed(orangeLedProps);

PulseLED greenPulseLed(greenLed, 10);

Button::Properties userButtonProps {
	GPIOA, GPIO_Pin_0, RCC_AHB1Periph_GPIOA, EXTI_Line0, EXTI_PortSourceGPIOA, EXTI_PinSource0, EXTI0_IRQn
};
Button infoButton(userButtonProps);

void handleInfoButtonInterrupt(void*) {
	printf(
		"\r\nInfo:"
		"\r\n  mainCycles = %lu"
		"\r\n",
		mainCycles);
}

int main(void)
{

	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4);	// 4 bits for pre-emption priority, 0 bits for non-preemptive subpriority
	infoButton.setPriority(2,0);

	initUART();
	
	greenLed.init();
	redLed.init();
	blueLed.init();
	orangeLed.init();

	greenPulseLed.init();

	infoButton.setPressedListener(handleInfoButtonInterrupt, nullptr);
	infoButton.init();

	// Create a task
	BaseType_t ret = xTaskCreate(blinkTask, "blink", configMINIMAL_STACK_SIZE, NULL, 1, NULL);

	if (ret == pdTRUE) {
		printf("System Started!\n");
		vTaskStartScheduler();  // should never return
	} else {
		printf("System Error!\n");
	}
}


void initUART(){
	// Enable pins used by UART2, set them to their alterantive (UART2) function
	RCC_AHB1PeriphClockCmd(uart2Props.clkGPIO, ENABLE);

	GPIO_PinAFConfig(uart2Props.gpio, uart2Props.pinSourceTX, uart2Props.afConfig); // alternative function USARTx_TX
	GPIO_PinAFConfig(uart2Props.gpio, uart2Props.pinSourceRX, uart2Props.afConfig); // alternative function USARTx_RX

	GPIO_InitTypeDef gpioInitStruct;
	gpioInitStruct.GPIO_Pin = uart2Props.pinTX | uart2Props.pinRX;
	gpioInitStruct.GPIO_Mode = GPIO_Mode_AF;
	gpioInitStruct.GPIO_Speed = GPIO_Speed_50MHz;
	gpioInitStruct.GPIO_OType = GPIO_OType_PP;
	gpioInitStruct.GPIO_PuPd = GPIO_PuPd_UP;

	GPIO_Init(uart2Props.gpio, &gpioInitStruct);


	uart2Props.clkUSARTCmdFun(uart2Props.clkUSART, ENABLE);

	USART_InitTypeDef usartInitStruct;
	usartInitStruct.USART_BaudRate = uart2Props.baudRate;
	usartInitStruct.USART_WordLength = USART_WordLength_8b;
	usartInitStruct.USART_StopBits = USART_StopBits_1;
	usartInitStruct.USART_Parity = USART_Parity_No;
	usartInitStruct.USART_Mode = USART_Mode_Tx | USART_Mode_Rx;
	usartInitStruct.USART_HardwareFlowControl = USART_HardwareFlowControl_None;

	USART_Init(uart2Props.usart, &usartInitStruct);

	NVIC_InitTypeDef nvicInitStruct;

/*	// Enable the USART Interrupt
	nvicInitStruct.NVIC_IRQChannel = uart2Props.irqn;
	nvicInitStruct.NVIC_IRQChannelPreemptionPriority = 8;
	nvicInitStruct.NVIC_IRQChannelSubPriority = 0;
	nvicInitStruct.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init(&nvicInitStruct);
*/
	USART_Cmd(uart2Props.usart, ENABLE);
}

int _write(int file, char * ptr, int len) {
	for(char* c = ptr; c < ptr + len; c++){
		while(!(uart2Props.usart->SR & USART_FLAG_TXE)) {
			// wait here
			volatile int keepme = 1;
		}
		uart2Props.usart->DR = *c;		
	}
	return len;
}
