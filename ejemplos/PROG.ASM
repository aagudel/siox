Include<P16F873.INC>   
LIST P=16F873, R=HEX

S0__	EQU	021H
S1__	EQU	022H
i_	EQU	023H
t_	EQU	024H
conf_	EQU	025H

;--VARIABLES-------------------

	ORG	0

	GOTO	_PPAL
;--FUNCIONES-------------------

	CLRW

configurar_puerto_B_:
	MOVF	conf_,0

	
	TRIS 	PORTB		;CONFIGURAR EL PUERTO B

	RETURN

;--PRINCIPAL--------------------

_PPAL	CLRW

	MOVLW	0FFH
	MOVWF	conf_
	CALL	configurar_puerto_B_
	MOVF	PORTB,0
	MOVWF	t_
	MOVLW	0AH
	MOVWF	i_
_WHL0:
	MOVLW	00H
	MOVWF	S1__
	MOVF	i_,0
	SUBWF	S1__,0
	BTFSC	STATUS,0
	GOTO	_ELS0
_WHL1:
	MOVF	PORTB,0
	MOVWF	S1__
	MOVF	t_,0
	SUBWF	S1__,0
	BTFSS	STATUS,2
	GOTO	_ELS1
	GOTO	_WHL1
_ELS1:
	DECF	i_
	MOVF	PORTB,0
	MOVWF	t_
	GOTO	_WHL0
_ELS0:

	SLEEP

	END
;------------------------------


