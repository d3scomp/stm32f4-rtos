#pragma once

#include <cstdint>

/**
 * Initialize UART console
 */
void initUARTConsole(uint32_t baud_rate);

/**
 * Provide _write syscall
 */
extern "C" {
	int _write(int file, char* ptr, int len);
}
