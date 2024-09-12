		AREA mycode, CODE, READONLY
		EXPORT __main
		ALIGN
		ENTRY
__main	PROC
		; Enable GPIO Clock (Power on)
		MOVW 	R2, #0x104C
		MOVT 	R2, #0x4002
		LDR 	R0, [R2]
		ORR 	R0, #4
		STR 	R0, [R2]

		; Set PC0 as output, PC4 as input
		MOVW 	R2, #0x0800
		MOVT 	R2, #0x4800 ; Address of GPIOC_MODER
		; 0000 0000 0000 0000 0000 1000 0000 0000
		;                      7 6  5 4  3 2  1 0
		LDR 	R0, [R2]
		MOVW 	R0, #0xFCFD
		MOVT 	R0, #0xFFFF
		STR 	R0, [R2]
		; The default state of an input GPIO pin is "floating," meaning the pin is not connected to a voltage source or ground, so the logic is not determinable
		; There is an internal pull up resistor on PC4, and we must enable it so that when it is not connected to ground, it is HI by default :)
		; set internal pull-up resistor on PC4
		LDR		R3, [R2, #0x0C] ; address of GPIOC_PUPDR
		BIC		R3, #0x200
		ORR		R3, R3, #0x100
		STR		R3, [R2, #0x0C]
		
		; Now, we continuously loop, checking for inputs on the button
loop	LDR 	R3, [R2, #0x10] ; R2 is the value of GPIOC_IDR (shows if input pins are on or off)	
		; 0000 0000 0001 0000
		;Set PC0 as ON if input
		;Easiest way would be bitwise shift right 4 bits then negate
		LSR		R3, R3, #4 ; Shift to the right 4, where odr bit is for led
		; 0000 0000 0000 0001
		; If on 1-0 = 1 if off 1 - 1 = 0!
		; 0000 0000 0000 0001
		RSB		R3, R3, #0x01
		
		STR		R3, [R2, #0x14]
		B		loop
		;PC4 active-low logic, so push means its gonna give us a zero
		
		; Your code goes above this line
		ENDP
		END