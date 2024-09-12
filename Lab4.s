		AREA mycode, CODE, READONLY
		EXPORT __main
		ALIGN
		ENTRY
__main	PROC
		; Group: Andrew Bilotti & Joshua Wynn
		; Enable GPIO Clock (Power on)
		MOVW 	R2, #0x104C
		MOVT 	R2, #0x4002
		LDR 	R0, [R2]
		ORR 	R0, #4
		STR 	R0, [R2]

		; Set PC0-PC3, PC8-PC11 as outputs, PC4-PC5 as inputs
		MOVW 	R2, #0x0800
		MOVT 	R2, #0x4800 ; address of GPIOC_MODER

		LDR 	R0, [R2]
		MOVW 	R0, #0xF055
		MOVT 	R0, #0xFF55
		STR 	R0, [R2]
		
		; set internal pull-up resistors on PC4/PC5
		LDR		R3, [R2, #0x0C] ; address of GPIOC_PUPDR
		BIC		R3, #0xA00
		ORR		R3, R3, #0x500
		STR		R3, [R2, #0x0C]
		
		MOV 	R0, #0 ; R0 always holds the value to show on the LEDs
		
		; Now, we continuously loop, checking for inputs on the buttons
		; and updating R0 when necessary, then showing its value on the LEDs
loop	LDR 	R3, [R2, #0x10] ; address of GPIOC_IDR (shows if input pins are on or off)	
		; TODO: Determine if you should jump to button1, button2, or show
		; based on the value in R2
		
		;IDR tells me if output pins are on and off too, which is weird.
		;So we need to reset all but bits 4 and 5 (PC4 and PC5)
		;0000 0000 00XX 0000
		BFC R3, #0, #4
		BFC R3, #6, #10
		
		; PC_4 for increment and PC_5 for decrement
		
		CMP R3, #0x30
		BEQ show ; Buttons arent pressed
		CMP R3, #0x20 ; PC4 pressed
		BEQ button1
		CMP R3, #0x10 ; PC5 pressed
		BEQ button2
		
		B		loop
		
		
		
button1	; TODO: Increment R0 and branch to the next appropriate label
		CMP R0, #0xFF
		BEQ loop
		ADD R0, R0, #1
		B		waitbutton
		
button2	; TODO: Decrement R0 and branch to the next appropriate label
		CMP R0, #0x00
		BEQ loop
		SUB R0, R0, #1
		B		waitbutton
		
show	; display N on LEDs after updating value
		MOV		R3, R0
		UBFX	R1, R3, #0, #4
		LSR 	R3, R3, #4
		BFI 	R1, R3, #8, #4
		STR 	R1, [R2, #0x14]
		B loop
		
waitbutton
		LDR R3, [R2, #0x10]
		BFC R3, #0, #4
		BFC R3, #6, #10
		CMP R3, #0x30
		BEQ show
		B waitbutton
		
		; Your code goes above this line
		ENDP
		END