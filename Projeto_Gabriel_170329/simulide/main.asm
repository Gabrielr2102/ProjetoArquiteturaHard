.INCLUDE "m328pdef.inc"
.nolist
.list

.ORG 0x0000

	rjmp start
	
start:
	;garantir que o stack pointer não inicie na posição de memória da RAM
	eor r1, r1
	out SREG, r1
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

setup: 
	ldi r16, 0xff ;carregando 0xffh registrador 16
	out ddrb, r16 ;portasB como saída

	


;led_on:
	;sbi PORTB, PB1
	;rjmp loop

configADC0: ;Configura
	ldi r16, 0x00
	sts ADMUX, r16
	;desativando a referencia de 1,1V para 5V

	ldi r16, (1<<ADEN) | (1<<ADPS0) | (1<<ADPS1) | (1<<ADPS2)
	sts ADCSRA, r16 ;Após definir as interrupções é passado para o registro

loop:
	;sbis PIND, PD6
	;rjmp led_on
	;cbi PORTD, PD7
	;rjmp loop
	
	lds r16, ADCSRA
	ori r16, (1<<ADSC) ;inicia a conversão
	sts ADCSRA, r16
	
ler_adc0: ;Enquanto ADSC estiver em 1 continua no loop
	lds r16, ADCSRA
	sbrc r16, ADSC ;Enquanto não for 0 ele vai permanecer nesse loop, o que faz ele permanecer no loop é rjmp
	rjmp ler_adc0
	
ler_H_L_ADC0: ;valores de adc0 HIGH e LOW (5V/0V)
	lds r24, ADCL
	lds r25, ADCH

LED_ON_LED_OFF_ADC0_value:
	cpi r25,3 ; Enquanto a luz do laser estiver focado no sensor, o Led vai permanecer apagado, ou seja, nenhuma pessoa passou.
	brsh LED_ON
	cbi PORTB, PB1
	rjmp loop

LED_ON:
	sbi PORTB, PB1
	rjmp loop
	