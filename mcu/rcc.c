#include <stdint.h>

#define RCC_BASE     0x58000000UL
#define GPIOA_BASE   0x48000000UL

#define RCC_AHB2ENR  (*(volatile uint32_t *)(RCC_BASE + 0x4C))

#define GPIOA_MODER  (*(volatile uint32_t *)(GPIOA_BASE + 0x00))
#define GPIOA_OTYPER (*(volatile uint32_t *)(GPIOA_BASE + 0x04))
#define GPIOA_ODR    (*(volatile uint32_t *)(GPIOA_BASE + 0x14))

void rcc_init()
{
    RCC_AHB2ENR |= (1U << 0);

    /* Brief delay to allow clock to stabilize (not strictly required) */
    for (volatile int i = 0; i < 100; i++);

    GPIOA_MODER &= ~(0x3U << (2 * 2));  /* Clear mode bits for PA2 (bits 5:4) */
    GPIOA_MODER |=  (0x1U << (2 * 2));  /* Set PA2 mode = 01 (general-purpose output) */
    
    GPIOA_OTYPER &= ~(1U << 2);  /* 0 = push-pull */
}
