	Include<P16F873.INC>   
	LIST P=16F873, R=HEX

S0__	EQU	021H
S1__	EQU	022H
a_	EQU	023H
b_	EQU	024H
c_	EQU	025H
mult1_	EQU	026H
mult2_	EQU	027H
rmult_	EQU	028H
cmult_	EQU	029H
dndo_	EQU	02AH
dsor_	EQU	02BH
rdiv_	EQU	02CH
cdiv_	EQU	02DH
mpr2_	EQU	02EH
dpr2_	EQU	02FH

;--VARIABLES-------------------

	ORG	0

	GOTO	_PPAL
;--FUNCIONES-------------------

	CLRW

mult_:
	MOVLW	00H
	MOVWF	rmult_
	MOVLW	00H
	MOVWF	cmult_
_WHL0:
	MOVF	cmult_,0
	MOVWF	S1__
	MOVF	mult2_,0
	SUBWF	S1__,0
	BTFSC	STATUS,0
	GOTO	_ELS0
	MOVF	rmult_,0
	ADDWF	mult1_,0
	MOVWF	rmult_
	MOVF	cmult_,0
	ADDLW	1H
	MOVWF	cmult_
	GOTO	_WHL0
_ELS0:
	MOVF	rmult_,0
	RETURN

	RETURN
div_:
	MOVF	dsor_,0
	MOVWF	cdiv_
	MOVLW	00H
	MOVWF	rdiv_
_WHL1:
	MOVF	dndo_,0
	MOVWF	S1__
	MOVF	cdiv_,0
	SUBWF	S1__,0
	BTFSS	STATUS,0
	GOTO	_ELS1
	MOVF	cdiv_,0
	ADDWF	dsor_,0
	MOVWF	cdiv_
	INCF	rdiv_
	GOTO	_WHL1
_ELS1:
	MOVF	rdiv_,0
	RETURN

	RETURN
multpor2_:


	RLF	mpr2_

	MOVF	mpr2_,0
	RETURN

	RETURN
divpor2_:


	RRF	dpr2_

	MOVF	dpr2_,0
	RETURN

	RETURN

;--PRINCIPAL--------------------

_PPAL	CLRW

	MOVLW	08H
	MOVWF	a_
	MOVLW	0AH
	MOVWF	b_
	MOVLW	0FH
	MOVWF	c_
	MOVF	a_,0
	MOVWF	S1__
	MOVLW	0AH
	SUBWF	S1__,0
	BTFSC	STATUS,0
	GOTO	_ELS2
	MOVF	a_,0
	MOVWF	mult1_
	MOVF	b_,0
	MOVWF	mult2_
	CALL	mult_
	MOVWF	a_
_ELS2:
	MOVLW	064H
	MOVWF	dndo_
	MOVLW	030H
	MOVWF	dsor_
	CALL	div_
	MOVWF	b_
	MOVLW	01EH
	MOVWF	mpr2_
	CALL	multpor2_
	MOVWF	c_

	SLEEP

	END
;------------------------------


