#include "p16f877a.inc"

#define BANCO1	bsf STATUS, RP0
#define BANCO0	bcf STATUS, RP0

; __config 0xFFBA
 __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_ON & _CPD_OFF & _WRT_OFF & _CP_OFF
 
 CBLOCK 20h	    ; cria registradores apartir da 20
 contador
 contador2

 endc
 
 org 0
 
 BANCO1
 
 movlw 0
 movwf TRISD		; porta D é saída
 
 movlw b'11101100'	; PSMODE = 0 para porta D ser I/O
 movwf TRISE		; bits 0 e 1 da porta E são saídas
 
 movlw b'00001110'	; pinos configurados como digitais
 movwf ADCON1
 
 BANCO0
 
valor_isento

 call inicia_lcd
 movlw 'M'
 call escreve_dado_lcd
 movlw 'O'
 call escreve_dado_lcd
 movlw 'T'
 call escreve_dado_lcd
 movlw 'O'
 call escreve_dado_lcd
 movlw '-'
 call escreve_dado_lcd
 movlw 'I'
 call escreve_dado_lcd
 movlw 'S'
 call escreve_dado_lcd
 movlw 'E'
 call escreve_dado_lcd
 movlw 'N'
 call escreve_dado_lcd
 movlw 'T'
 call escreve_dado_lcd
 movlw 'A'
 call escreve_dado_lcd
 return

valor_5

 call inicia_lcd
 movlw 'V'
 call escreve_dado_lcd
 movlw 'A'
 call escreve_dado_lcd
 movlw 'L'
 call escreve_dado_lcd
 movlw 'O'
 call escreve_dado_lcd
 movlw 'R'
 call escreve_dado_lcd
 movlw '-'
 call escreve_dado_lcd
 movlw 'R'
 call escreve_dado_lcd
 movlw '$'
 call escreve_dado_lcd
 movlw '5'
 call escreve_dado_lcd
 return 

valor_7

 call inicia_lcd
 movlw 'V'
 call escreve_dado_lcd
 movlw 'A'
 call escreve_dado_lcd
 movlw 'L'
 call escreve_dado_lcd
 movlw 'O'
 call escreve_dado_lcd
 movlw 'R'
 call escreve_dado_lcd
 movlw '-'
 call escreve_dado_lcd
 movlw 'R'
 call escreve_dado_lcd
 movlw '$'
 call escreve_dado_lcd
 movlw '7'
 call escreve_dado_lcd
 return

valor_10

 call inicia_lcd
 movlw 'V'
 call escreve_dado_lcd
 movlw 'A'
 call escreve_dado_lcd
 movlw 'L'
 call escreve_dado_lcd
 movlw 'O'
 call escreve_dado_lcd
 movlw 'R'
 call escreve_dado_lcd
 movlw '-'
 call escreve_dado_lcd
 movlw 'R'
 call escreve_dado_lcd
 movlw '$'
 call escreve_dado_lcd
 movlw '1'
 call escreve_dado_lcd
 movlw '0'
 call escreve_dado_lcd
 return

msg_bem_vindo

 call inicia_lcd
 movlw 'B'
 call escreve_dado_lcd
 movlw 'E'
 call escreve_dado_lcd
 movlw 'M'
 call escreve_dado_lcd
 movlw '-'
 call escreve_dado_lcd
 movlw 'V'
 call escreve_dado_lcd
 movlw 'I'
 call escreve_dado_lcd
 movlw 'N'
 call escreve_dado_lcd
 movlw 'D'
 call escreve_dado_lcd
 movlw 'O'
 call escreve_dado_lcd
 return

valor_falta

 call inicia_lcd
 movlw 'F'
 call escreve_dado_lcd
 movlw 'A'
 call escreve_dado_lcd
 movlw 'L'
 call escreve_dado_lcd
 movlw 'T'
 call escreve_dado_lcd
 movlw 'A'
 call escreve_dado_lcd
 movlw '-'
 call escreve_dado_lcd
 movlw 'R'
 call escreve_dado_lcd
 movlw '$'
 call escreve_dado_lcd
 return

msg_troco

 call inicia_lcd
 movlw 'T'
 call escreve_dado_lcd
 movlw 'R'
 call escreve_dado_lcd
 movlw 'O'
 call escreve_dado_lcd
 movlw 'C'
 call escreve_dado_lcd
 movlw 'O'
 call escreve_dado_lcd
 movlw '-'
 call escreve_dado_lcd
 movlw 'R'
 call escreve_dado_lcd
 movlw '$'
 call escreve_dado_lcd
 return

msg_cancela_aberta

 call inicia_lcd
 movlw 'C'
 call escreve_dado_lcd
 movlw 'A'
 call escreve_dado_lcd
 movlw 'N'
 call escreve_dado_lcd
 movlw 'C'
 call escreve_dado_lcd
 movlw 'E'
 call escreve_dado_lcd
 movlw 'L'
 call escreve_dado_lcd
 movlw 'A'
 call escreve_dado_lcd
 movlw '-'
 call escreve_dado_lcd
 movlw 'A'
 call escreve_dado_lcd
 movlw 'B'
 call escreve_dado_lcd
 movlw 'E'
 call escreve_dado_lcd
 movlw 'R'
 call escreve_dado_lcd
 movlw 'T'
 call escreve_dado_lcd
 movlw 'A'
 call escreve_dado_lcd
return

 goto $			; Trava programa
 
inicia_lcd
 movlw 38h
 call escreve_comando_lcd
 movlw 38h
 call escreve_comando_lcd
 movlw 38h
 call escreve_comando_lcd
 movlw 0Ch
 call escreve_comando_lcd
 movlw 06h
 call escreve_comando_lcd
 movlw 01h
 call escreve_comando_lcd
 call atraso_limpa_lcd
 return
 
escreve_comando_lcd
 bcf PORTE, RE0		; Define dado no LCD(RS=1)
 movwf PORTD
 bsf PORTE, RE1		; ativar ENABLE do LCD
 bcf PORTE, RE1		; Desativar ENABLE do LCD
 call atraso_lcd
 return
 
escreve_dado_lcd
 bsf PORTE, RE0		; Define dado no LCD(RS=1)
 movwf PORTD
 bsf PORTE, RE1		; ativar ENABLE do LCD
 bcf PORTE, RE1		; Desativar ENABLE do LCD
 call atraso_lcd
 return
 
atraso_lcd		; Atraso de 40us para LCD
 movlw 26		;8clocks (pq ele deu um call então zero... começo do 0... o segundo ja é 4 clocks)
 movwf contador		; 4 clocks
ret_atraso_lcd
 decfsz contador	; 8 clocks (qndo da saltos é 8 clocks), este e o goto vai ser repetido N vezes
 goto ret_atraso_lcd	; 4 clocks
 return
 
atraso_limpa_lcd
 movlw 40		;8clocks (pq ele deu um call então zero... começo do 0... o segundo ja é 4 clocks)
 movwf contador2	; 4 clocks
ret_atraso_limpa_lcd
 call atraso_lcd
 decfsz contador2	
 goto ret_atraso_limpa_lcd	
 return
 
 end


