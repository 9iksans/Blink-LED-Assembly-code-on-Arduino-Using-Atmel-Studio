;
; Blink.asm
;
; Created: 11/20/2018 6:15:51 PM
; Author : ASUS
;


;************************************
; written by: 1o_o7 
; date: <2014|10|29>
; version: 1.0
; file saved as: blink.asm
; for AVR: atmega328p
; clock frequency: 16MHz (optional)
;************************************

; Program funcion:---------------------
; counts off seconds by blinking an LED
;
; PD4 ---> LED ---> R(330 ohm) ---> GND
;
;--------------------------------------

.nolist
.include "./m328Pdef.inc"
.list

;==============
; Declarations:

.def temp = r16
.def overflows = r17
.def overflows2 = r18
.def temp1=r19


.org 0x0000              ; memory (PC) location of reset handler
rjmp Reset               ; jmp costs 2 cpu cycles and rjmp costs only 1
                         ; so unless you need to jump more than 8k bytes
                         ; you only need rjmp. Some microcontrollers therefore only 
                         ; have rjmp and not jmp
.org 0x001A

rjmp overflow_handler
.org 0x0020            ; memory location of Timer0 overflow handler
rjmp overflow_handler1    ; go here if a timer0 overflow interrupt occurs 


;============

Reset: 
ldi R20, HIGH(RAMEND)
OUT SPH,R20
LDI R20,LOW(RAMEND)
OUT SPL,R20
   ldi temp,  0b00000011
   sts 0x45, temp     
   ldi temp1, 0b00000100
   sts TCCR1B,temp1
   ldi temp, 0x01
   sts TIMSK0, temp     
   ldi temp1, 0x01
   sts TIMSK1, temp1
   
   sei                   ; enable global interrupts -- equivalent to "sbi SREG, I"

   clr temp
   clr temp1
   sts TCNT0, temp      
   sts 0x84, temp1

   sbi DDRB, 0            ; set PB4 to output
   sbi DDRB, 1
;======================
; Main body of program:

blink:
   sbi PORTB,0          ; turn on LED on PD4
   rcall delay           ; delay will be 1/2 second
   cbi PORTB,0           ; turn off LED on PD4
   rcall delay           ; delay will be 1/2 second
   SBI PORTB,1
   RCALL delay1
   CBI PORTB,1
   RCALL delay1
   rjmp blink            ; loop back to the start
  
delay:
   clr overflows         ; set overflows to 0 
   sec_count:
     cpi overflows,30    ; compare number of overflows and 30
   brne sec_count        ; branch to back to sec_count if not equal 
   ret                   ; if 30 overflows have occured return to blink
delay1:
   clr overflows2         ; set overflows to 0 
   sec_count1:
     cpi overflows2,30    ; compare number of overflows and 30
   brne sec_count1        ; branch to back to sec_count if not equal 
   ret                   ; if 30 overflows have occured return to blink

overflow_handler: 
   inc overflows         ; add 1 to the overflows variable
   cpi overflows, 61     ; compare with 61
   brne PC+2             ; Program Counter + 2 (skip next line) if not equal
   clr overflows         ; if 61 overflows occured reset the counter to zero
   reti                  ; return from interrupt

overflow_handler1: 
   inc overflows2         ; add 1 to the overflows variable
   cpi overflows2, 61     ; compare with 61
   brne PC+2             ; Program Counter + 2 (skip next line) if not equal
   clr overflows2         ; if 61 overflows occured reset the counter to zero
   reti                  ; return from interrupt