;<<Programa_Ejemplo>>			

#var#

i.
t.

#fnn#

configurar_puerto_B(byte conf)  ;Bits de conf 1=entrada 0=salida
{
$W=conf.
[	
	TRIS 	PORTB		;CONFIGURAR EL PUERTO B
]
}
#ppl#
;Programa que detecta cambios en el puerto B y termina luego de 10 cambios

configurar_puerto_B(255).	;Configura para todos salida

t=$PORTB.
i=10.

while(i>0)
{
   while($PORTB=?t)
   {	
   }		
   i--.
   t=$PORTB.
}

#end#
