;<<Programa_uso_serial>>
#var# 

byte caracter=0.

[
PTOA		EQU		5H		
PTOB		EQU		6H
TX		EQU		7H
RX		EQU		6H
]

;COMUNICACION SERIAL, VELOCIDAD 12OO, PARIDAD NINGUNA, NUMERO DE BITS 8, BIT DE PARADA 1.
;CRISTAL 4MHZ, PARA PIC 16F873.

#fnn#

byte inic_serial_pic()
byte $TRANS. $R0D. $R0E. $R14. $R1B. $LOOPS. 
byte $LOOPS2. $CONTA. $REG. $RECEP.
{


[
	BSF	STATUS,RP0
	MOVLW	00H
	MOVWF	TRISA
	MOVLW	7FH
	MOVWF	TRISB
	BCF	STATUS,RP0
	BSF	PTOB,TX
	CLRF	CONTA
]
	return	1. 	
}

byte enviar_serial(byte __dato)
{
	$TRANS=__dato.
[
	MOVWF	TRANS		;RUTINA PARA ENVIAR ENVIA LO QUE HAY EN TRANS
XMRT	MOVLW	8
	MOVWF	R0D
	BCF	PTOB,TX
	CALL	DELAY1
XNEXT	BCF	PTOB,TX
	BCF	STATUS,C
	RRF	TRANS
	BTFSC	STATUS,C
	BSF	PTOB,TX
	CALL	DELAY1
	DECFSZ	R0D
	GOTO	XNEXT
	BSF	PTOB,TX
	CALL	DELAY1
	RETLW	0
]
}

byte recibir_serial()
{
[
RECIBIR		NOP			;RUTINA PARA RECIBIR, RECIBE EN EL REGISTRO RECEP 
		CLRF	RECEP
		BTFSC	PTOB,RX
		GOTO	RECIBIR
		CALL	UNOYMED
RCVR		MOVLW	8
		MOVWF	CONTA
RNEXT		BCF	STATUS,C
		BTFSC	PTOB,RX
		BSF	STATUS,C
		RRF	RECEP
		CALL	DELAY1
		DECFSZ	CONTA
		GOTO	RNEXT
		MOVF	RECEP,W
		RETURN
]
}

byte _retardo__()
{
[
UNOYMED		MOVLW	.249		;RETARDO PARA 1200 BAUDIOS, ALTERE 249 y 166 
		GOTO	STARTUP		;PARA OTRAS VELOCIDADES 
DELAY1		MOVLW	.166
STARTUP		MOVWF	R0E
REDO		NOP
		NOP
		DECFSZ	R0E
		GOTO	REDO
		RETLW	0
]
}

#ppl#

;El siguiente programa recibe un caracter y env�a su valor mas uno
;hasta que llege a 100.
	
inic_serial_pic().

while(caracter<=100)
{
   caracter=recibir_serial().   
   enviar_serial(caracter).
}

#end#

