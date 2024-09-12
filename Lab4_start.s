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

		LDR 	R0, [R2]
		MOVW 	R0, #0xFCFD
		MOVT 	R0, #0xFFFF
		STR 	R0, [R2]
		
		; set internal pull-up resistor on PC4
		LDR		R3, [R2, #0x0C] ; address of GPIOC_PUPDR
		BIC		R3, #0x200
		ORR		R3, R3, #0x100
		STR		R3, [R2, #0x0C]
		
		; Now, we continuously loop, checking for inputs on the button
loop	LDR 	R3, [R2, #0x10] ; R2 is the value of GPIOC_IDR (shows if input pins are on or off)	
		
		B		loop
		
		; Your code goes above this line
		ENDP
		END