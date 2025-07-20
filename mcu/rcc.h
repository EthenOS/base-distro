#ifndef _RCC_H
#define _RCC_H

#define RCC_BASE     0x58000000UL
#define GPIOA_BASE   0x48000000UL

#define RCC_AHB2ENR  (*(volatile uint32_t *)(RCC_BASE + 0x4C))

#define GPIOA_MODER  (*(volatile uint32_t *)(GPIOA_BASE + 0x00))
#define GPIOA_OTYPER (*(volatile uint32_t *)(GPIOA_BASE + 0x04))
#define GPIOA_ODR    (*(volatile uint32_t *)(GPIOA_BASE + 0x14))

void rcc_init();

#endif // _RCC_H
