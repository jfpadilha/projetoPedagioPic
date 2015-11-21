    ;balanca = 2
    ;kit pedagio 1
    
    #include "p16f877a.inc"

;Bancos
    #define BANCO1	bsf STATUS, RP0
    #define BANCO0	bcf STATUS, RP0

;Entradas
    #define sp      PORTA, RA2     ;sensor de peso
    #define n2      PORTD, RD0
    #define n5      PORTD, RD1
;Saidas
    #define rn
    #define ac      PORTE, RE2
    #define sm      PORTC, RC3
    #define lm      PORTC, RC4
    #define la      PORTB, RB0

; __config 0xFFBA
 __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_ON & _CPD_OFF & _WRT_OFF & _CP_OFF

 CBLOCK 20h	    ; cria registradores apartir da 20
    valor_entrada
    valor_salvo
    valor_restante
    valor_veiculo
    peso_veiculo
    qtd_troco
    valor_teste
    contador
    contador2
 endc

 org 0
 
 ;Inicializacoes
    movlw 0
    movwf valor_entrada
    movwf valor_salvo
    movwf valor_restante
    movwf valor_veiculo
    movwf valor_teste
    movwf qtd_troco
 

 BANCO1
 
 ;DEFINIR SAIDAS
    movlw 0
    movwf TRISB             ; porta B é saída 
    movlw b'00000111'       ; PSMODE = 0 para porta D ser I/O
    movwf TRISE             ; bits 0 e 1 da porta E são saídas 
    movlw b'00000111'       ; pinos configurados como digitais
    movwf TRISC             ; bits 0 e 1 da porta E são saídas 
    movlw b'00000111'       ; pinos configurados como digitais
    movwf ADCON1

;------------------ 
 
 movlw b'00000111'          ; timer 0 com clock interno e prescaler 256
 movwf	OPTION_REG
 
 BANCO0 
    movlw b'00110001'       ; timer 1 com clock interno e prescaler 8
    movwf T1CON
 
    call inicia_lcd
    call msg_bem_vindo
    bcf ac
    bcf lm
    bcf sm
    bcf la
 
  
inicio                    ;ver se tem erro
  
;configuracao pinos
ler_entrada_analogica
    BANCO1
    movlw b'00000011'       ;pinos configurados para analogico
    movwf ADCON1   
    BANCO0
    bsf ADCON0, 2           ;set bit 2 do adcon0 (GO/DONE)
    
testa_ad
    btfsc ADCON0, 2         ;testa se eh zero, se for pula    
    goto testa_ad           ;se  != zero aqui
    
    movfw ADRESH            ;zero executa aqui
    movwf peso_veiculo      ;0v = 0 5v = 255    
    
    movlw peso_veiculo
    sublw 195
    movwf valor_teste
    
    btfsc STATUS, C               ;se for zero, pula
    goto identifica_veiculo         ;não
    goto ler_entrada_analogica      ;volta

identifica_veiculo
    ;testa caminhao 4 eixos
    goto abrir_cancela
    
;    movlw peso_veiculo
;    sublw 225
;    movwf valor_teste    
;    btfsc STATUS, C               ;se for zero, pula
;;    goto
    
seta_valor10
    
seta_valor7
    
seta_valor5
    
    
ler_valor_entrada
    btfsc n2
    goto ler_valor_entrada  ;se eh zero
    
ler_n5                  ;sim
    btfsc n2
    goto ler_valor_entrada

 
 goto $
 
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
    movlw ' '
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
    movlw ' '
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
    movlw ' '
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
    movlw ' '
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
    movlw ' '
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
    movlw ' '
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
    movlw ' '
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
    movlw ' '
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
 
 ;------ 1 segundo------
espera_1s
    movlw 20
    movwf contador
    movlw 60		; valor para 196 contagens (50ms)
    movwf TMR0		; 256  -  196  = 60

aguarda_estouro 
    btfss INTCON, TMR0IF	; espera timer0 estourar
    goto aguarda_estouro
    movlw 60		; reprograma para 196 contagens (50ms)
    movwf TMR0		; 256  -  196  = 60
    bcf INTCON, TMR0IF	; limpa flag de estouro
    decfsz contador	; aguarda 20 ocorrencias ( 20 x 50ms = 1s)
    goto aguarda_estouro
    return
 
 ;------------| PROCESSAMENTO DE TROCO |------------

devolve_moedas
    bsf sm
    call espera_1s
    bcf sm
    call espera_1s
    bsf lm
    call espera_1s
    bcf lm
    decfsz valor_restante
    call limpa_lcd
    call msg_cancela_aberta
    goto abrir_cancela
 
 ;------------| ABRIR/FECHAR CANCELA |------------
abrir_cancela
    bsf ac
    call limpa_lcd
    call inicia_lcd
    call msg_cancela_aberta
    call espera_1s
    call espera_1s
    call espera_1s
	
fechar_cancela
    bcf ac
    call limpa_lcd
    call inicia_lcd
    call msg_bem_vindo
    goto inicio
 
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
 
limpa_lcd
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