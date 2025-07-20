#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"

#include "rcc.h"

void main(void)
{
    rcc_init();
    for (;;) {
        GPIOA_ODR ^= (1U << 2);      /* Toggle PA2 output */
        /* Simple delay loop */
        for (volatile int j = 0; j < 100000; j++);
    }
}
