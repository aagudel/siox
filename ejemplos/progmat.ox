;<<Programa_Ejemplo>>			

#var#

a.
b.
c.

#fnn#


byte mult(mult1,mult2)		;Multiplica dos n�meros
byte rmult=0.
byte cmult=0.
{
	while(cmult<mult2)
	{
		rmult=rmult+mult1.     
		cmult=cmult+1.	
	}
	return rmult.
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

byte div(dndo,dsor)		;Divide dos n�meros
byte rdiv.
byte cdiv.
{
	cdiv=dsor.
	rdiv=0.
	while(cdiv<=dndo)
	{
		cdiv=cdiv+dsor.
		rdiv++.
	}
	return rdiv.
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

byte multpor2(byte mpr2)		;Multipica un numero por 2, versi�n r�pida
{
[
	RLF	mpr2_
]
	return mpr2.	
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

byte divpor2(byte dpr2)		;Divisi�n de un numero por 2, versi�n r�pida
{
[
	RRF	dpr2_
]
	return dpr2.	
}

#ppl#

a=8.
b=10.
c=15.

if(a<10)
{
   a=mult(a,b).
}
    	
b=div(100,48).

c=multpor2(30).

#end#
