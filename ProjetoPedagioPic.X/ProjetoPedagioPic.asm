    #include "p16f877a.inc"

; __config 0xFFBA
 __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_ON & _CPD_OFF & _WRT_OFF & _CP_OFF

 ;Bancos
    #define BANCO1  bsf STATUS, RP0
    #define BANCO0  bcf STATUS, RP0

;Entradas
    #define sp      PORTA, RA2
    #define n2      PORTD, RD0
    #define n5      PORTD, RD1
;Saidas
    #define rn
    #define ac      PORTE, RE2
    #define sm      PORTC, RC3
    #define lm      PORTC, RC4
    #define LED1    PORTB, 0
    #define beeps   PORTA, 5

 CBLOCK 20h                         ; cria registradores apartir da 20
    valor_entrada
    valor_salvo
    valor_restante
    valor_veiculo
    peso_veiculo
    contador
    contador2
    varpos1			;variavel que armazena numero convertido para colocar no LCD
    varpos2			;variavel que armazena numero convertido para colocar no LCD
    numbin
    tempo_30s_cancela
    tempo_20s_cancela
    contador_buzz
    contador_z
 endc
 
step	EQU	.10			;decremento do converte_bytes

 org 0 
        
 ;Inicializacoes
 BANCO0
    movlw 0
    movwf valor_entrada
    movwf valor_salvo
    movwf valor_restante
    movwf valor_veiculo
 
 ;DEFINIR SAIDAS
  BANCO1
    movlw b'11111110'
    movwf TRISB             ; porta B È saÌda 
    movlw b'11100000'       ; PSMODE = 0 para porta D ser I/O
    movwf TRISE             ; bits 0 e 1 da porta E s„o saÌdas 
    movlw b'00000000'       ; pinos configurados como digitais
    movwf TRISC             ; bits 0 e 1 da porta E s„o saÌdas 
    movlw b'00000000'       ; pinos configurados como digitais
    movwf TRISD             ; bits 0 e 1 da porta E s„o saÌdas 
    
;DEFINIR ENTRADAS
    movlw b'11111111'
    movwf TRISA
    movlw b'00000010'
    movwf ADCON1

;CONFIGURACAO PRESCALER
    movlw b'00000111'          ; timer 0 com clock interno e prescaler 256
    movwf OPTION_REG
 
  BANCO0 
    movlw b'00110001'       ; timer 1 com clock interno e prescaler 8
    movwf T1CON 
    call inicia_lcd
    call msg_bem_vindo
    bcf ac
    bcf lm
    bcf sm
    
inicio
    bcf LED1
    movlw 0
    movwf valor_salvo
    movlw b'01010001'
    movwf ADCON0
    call atraso_limpa_lcd    
    bsf ADCON0, GO_DONE           ;set bit 2 do adcon0 (GO/DONE)
    
;-----------balanÁa--------------
verifica_sensores

    bsf ADCON0, GO_DONE		  ;set bit 2 do adcon0 (GO/DONE)
volta_verifica_sensores
    btfsc ADCON0, GO_DONE
    goto volta_verifica_sensores

    movfw ADRESH
    movwf peso_veiculo

; -----------balanÁa veiculos----------------
verifica_veiculos
    movlw .180
    subwf peso_veiculo, W
    call espera_1s
    btfss STATUS, C
    goto verifica_sensores

    movlw .190
    subwf peso_veiculo, W
    btfss STATUS, C
    goto moto_isento

    movlw .198
    subwf peso_veiculo, W
    btfss STATUS, C
    goto seta_valor5

    movlw .205
    subwf peso_veiculo, W
    btfss STATUS, C
    goto seta_valor7

    movlw .253
    subwf peso_veiculo, W
    btfss STATUS, C
    goto seta_valor10
    goto verifica_sensores

moto_isento
    call limpa_lcd
    call valor_isento
    goto abrir_cancela
    
seta_valor10
    call limpa_lcd
    call veiculo_4_eixos
    call espera_2s
    call limpa_lcd
    call valor_10
    movlw .10
    movwf valor_veiculo
    goto ler_valor_entrada
    
seta_valor7
    call limpa_lcd
    call veiculo_3_eixos
    call espera_2s
    call limpa_lcd
    call valor_7
    movlw .7
    movwf valor_veiculo
    goto ler_valor_entrada
    
seta_valor5
    call limpa_lcd
    call veiculo_passeio
    call espera_2s
    call limpa_lcd
    call valor_5
    movlw .5
    movwf valor_veiculo
    goto ler_valor_entrada
    
ler_valor_entrada
    BANCO1
    movlw b'00000011'
    movwf TRISD             ;D como ENTRADA
    BANCO0
    movlw 0
    movwf valor_entrada
    bcf LED1
    movlw .24
    movwf tempo_30s_cancela
    
ler_valor_entrada_30s
    btfsc n2
    goto valor_entrada_2
    btfsc n5
    goto valor_entrada_5
    call espera_0.5s
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    call espera_0.5s
    decfsz tempo_30s_cancela
    goto ler_valor_entrada_30s
    goto pisca_led_moedas
    
pisca_led_moedas
    movlw .4
    movwf tempo_20s_cancela    
sensores_ativados_entrada
    btfsc n2
    goto valor_entrada_2
    btfsc n5
    goto valor_entrada_5 
    bsf LED1		    ;liga o led
    call espera_0.5s
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    call espera_0.5s
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    call espera_0.5s
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    call espera_0.5s
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    bcf LED1		    ;desliga o led
    call espera_0.5s
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    call espera_0.5s
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    call espera_0.5s
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    call espera_0.5s
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    decfsz tempo_20s_cancela
    goto sensores_ativados_entrada
    goto buzz
 
valor_entrada_2
    movlw 2
    movwf valor_entrada
    call espera_2s 
    goto verifica_valor_entrada
    
valor_entrada_5
    movlw 5
    movwf valor_entrada
    call espera_2s 
    goto verifica_valor_entrada
 
verifica_valor_entrada
    movf valor_entrada, W
    addwf valor_salvo, W
    movwf valor_salvo
    movf valor_veiculo, W
    subwf valor_salvo, W
    movwf valor_restante
    btfsc STATUS, Z
    goto msg_abrir_cancela
    btfsc STATUS, C
    goto devolve_moeda
    goto ler_valor_entrada_falta         

ler_valor_entrada_falta
    BANCO1
    movlw b'00000000'
    movwf TRISD             ;D como SAIDA
    BANCO0
    
    call limpa_lcd
    call valor_falta
    goto ler_valor_entrada
    
msg_abrir_cancela
    BANCO1
    movlw b'00000000'
    movwf TRISD             ;D como SAIDA
    BANCO0
    call limpa_lcd
    call tarifa_paga
    goto abrir_cancela
   
;------- | MENSAGENS | -------------
valor_isento
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
    movlw 'T'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'F'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw '$'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw '5'
    call escreve_dado_lcd
    return 

valor_7
    movlw 'T'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'F'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw '$'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw '7'
    call escreve_dado_lcd
    return

valor_10
    movlw 'T'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'F'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw '$'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw '1'
    call escreve_dado_lcd
    movlw '0'
    call escreve_dado_lcd
    return

msg_bem_vindo
    movlw ' '
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
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
    movlw 'P'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'G'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw '$'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movf valor_salvo, W   ;para valor_restante para W	
    movwf numbin		    ;move o valor_restante para numbin 
    call converte_bytes	    ;converte numero em unidade e dezena para colocar no LCD
    movf varpos2, W	    ;escreve no LCD o valor de W
    call escreve_dado_lcd
    return

msg_troco
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
    movlw ' '
    call escreve_dado_lcd
    movf valor_restante,W	
    movwf numbin		   
    call converte_bytes	    ;converte numero em unidade e dezena para colocar no LCD
    movf varpos2,W
    call escreve_dado_lcd
    return

msg_cancela_aberta
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
    
veiculo_passeio
    movlw 'V'
    call escreve_dado_lcd
    movlw 'E'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'C'
    call escreve_dado_lcd
    movlw 'U'
    call escreve_dado_lcd
    movlw 'L'
    call escreve_dado_lcd
    movlw '0'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'P'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'S'
    call escreve_dado_lcd
    movlw 'S'
    call escreve_dado_lcd
    movlw 'E'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    return
    
veiculo_3_eixos
    movlw 'V'
    call escreve_dado_lcd
    movlw 'E'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'C'
    call escreve_dado_lcd
    movlw 'U'
    call escreve_dado_lcd
    movlw 'L'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw '3'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'E'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'X'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw 'S'
    call escreve_dado_lcd
    return
    
veiculo_4_eixos
    movlw 'V'
    call escreve_dado_lcd
    movlw 'E'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'C'
    call escreve_dado_lcd
    movlw 'U'
    call escreve_dado_lcd
    movlw 'L'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw '4'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'E'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'X'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw 'S'
    call escreve_dado_lcd
    return
    
tarifa_paga
    movlw 'T'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'F'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'P'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'G'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    return
    
converte_bytes
    clrf	varpos1
    clrf	varpos2
    movf	numbin,W
    movwf	varpos2
conversor_1
    movlw	step		;MOVE O VALOR M√çNIMO PARA W
    subwf	varpos2,W	;SUBTRAI O VALOR DE W (10) DE VARPOS2
    btfss	STATUS,C	;TESTA CARRY. RESULTADO NEGATIVO?
    goto	conversor_2	
    movwf	varpos2
    incf	varpos1,F		
    goto	conversor_1
conversor_2		;FINAL DA CONVERS√O.
    movlw 0x30
    addwf varpos1,F	; AJUSTA P/ESCRITA EM CARACTER ASC II
    addwf varpos2,F	; AJUSTA P/ESCRITA EM CACACTER ASC II
    return
 
;------ | TEMPO 1/2 SEGUNDO | ------
espera_0.5s
    movlw 10
    movwf contador
    movlw 60       ; valor para 196 contagens (50ms)
    movwf TMR0     ; 256  -  196  = 60
aguarda_estouro_0.5s 
    btfss INTCON, TMR0IF   ; espera timer0 estourar
    goto aguarda_estouro_0.5s
    movlw 60       ; reprograma para 196 contagens (50ms)
    movwf TMR0     ; 256  -  196  = 60
    bcf INTCON, TMR0IF ; limpa flag de estouro
    decfsz contador    ; aguarda 20 ocorrencias ( 20 x 50ms = 1s)
    goto aguarda_estouro_0.5s
    return
    
;------ | TEMPO 1 SEGUNDO | ------
espera_1s
    movlw 20
    movwf contador
    movlw 60		 ; valor para 196 contagens (50ms)
    movwf TMR0		 ; 256  -  196  = 60

aguarda_estouro 
    btfss INTCON, TMR0IF    ; espera timer0 estourar
    goto aguarda_estouro
    movlw 60                ; reprograma para 196 contagens (50ms)
    movwf TMR0		 ; 256  -  196  = 60
    bcf INTCON, TMR0IF      ; limpa flag de estouro
    decfsz contador         ; aguarda 20 ocorrencias ( 20 x 50ms = 1s)
    goto aguarda_estouro
    return
 
;------ | TEMPO 2 SEGUNDOS | ------
espera_2s
    movlw 40
    movwf contador
    movlw 60		; valor para 196 contagens (50ms)
    movwf TMR0		; 256  -  196  = 60

aguarda_estouro_2s 
    btfss INTCON, TMR0IF   ; espera timer0 estourar
    goto aguarda_estouro_2s
    movlw 60		; reprograma para 196 contagens (50ms)
    movwf TMR0		; 256  -  196  = 60
    bcf INTCON, TMR0IF	; limpa flag de estouro
    decfsz contador	; aguarda 20 ocorrencias ( 20 x 50ms = 1s)
    goto aguarda_estouro_2s
    return
 
;------ | TEMPO 4 SEGUNDOS | ------
espera_4s
    movlw 80
    movwf contador
    movlw 60		; valor para 196 contagens (50ms)
    movwf TMR0		; 256  -  196  = 60

aguarda_estouro_4s 
    btfss INTCON, TMR0IF   ; espera timer0 estourar
    goto aguarda_estouro_4s
    movlw 60		; reprograma para 196 contagens (50ms)
    movwf TMR0		; 256  -  196  = 60
    bcf INTCON, TMR0IF	; limpa flag de estouro
    decfsz contador	; aguarda 20 ocorrencias ( 20 x 50ms = 1s)
    goto aguarda_estouro_4s
    return
 
;------------| PROCESSAMENTO DE TROCO |------------
devolve_moeda
    BANCO1
    movlw b'00000000'
    movwf TRISD             ;D como SAIDA
    BANCO0
    bcf LED1
    call limpa_lcd
    call tarifa_paga
    call espera_1s
    call limpa_lcd
    call msg_troco
 
devolve_moedas
    bsf sm
    call espera_1s
    bcf sm
    call espera_1s
    bsf lm
    call espera_1s
    bcf lm
    call espera_1s
    decfsz valor_restante
    goto devolve_moedas
 
 ;------------| ABRIR CANCELA |------------
abrir_cancela
    BANCO1
    movlw b'00000000'
    movwf TRISD             ;D como SAIDA
    movlw b'11111111'
    movwf TRISA
    BANCO0
    bcf LED1
    call espera_1s
    bsf ac
    call limpa_lcd
    call msg_cancela_aberta

    movlw .24
    movwf tempo_30s_cancela
sensores_ativados
    bsf ADCON0, GO_DONE		  ;set bit 2 do adcon0 (GO/DONE)
volta_sensores_ativados
    btfsc ADCON0, GO_DONE
    goto volta_sensores_ativados

    movfw ADRESH
    movwf peso_veiculo

    movlw .180
    subwf peso_veiculo, W
    btfss STATUS, C
    goto fechar_cancela
    call espera_1s
    decfsz tempo_30s_cancela
    goto sensores_ativados
    goto pisca_led

;------------| FECHAR CANCELA |------------
fechar_cancela
    BANCO1
    movlw b'11111111'
    movwf TRISA
    BANCO0
    call espera_4s
    bcf ac
    call limpa_lcd
    call msg_bem_vindo
    goto inicio
    
;-------------| PISCA LED |--------------------
pisca_led
    movlw .4
    movwf tempo_20s_cancela
verifica_sensores_saida
    bsf ADCON0, GO_DONE		  ;set bit 2 do adcon0 (GO/DONE)
volta_verifica_sensores_saida
    btfsc ADCON0, GO_DONE
    goto volta_verifica_sensores_saida

    movfw ADRESH
    movwf peso_veiculo

    movlw .180
    subwf peso_veiculo, W
    btfss STATUS, C
    goto fechar_cancela    
    bsf LED1
    call espera_1s
    movlw .180
    subwf peso_veiculo, W
    btfss STATUS, C
    goto fechar_cancela  
    call espera_1s
    movlw .180
    subwf peso_veiculo, W
    btfss STATUS, C
    goto fechar_cancela  
    bcf LED1
    call espera_1s
    movlw .180
    subwf peso_veiculo, W
    btfss STATUS, C
    goto fechar_cancela
    call espera_1s
    movlw .180
    subwf peso_veiculo, W
    btfss STATUS, C
    goto fechar_cancela  
    decfsz tempo_20s_cancela
    goto verifica_sensores_saida
    goto buzz_saida
    
inicia_lcd
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
    bcf PORTE, RE0      ; Define dado no LCD(RS=1)
    movwf PORTD
    bsf PORTE, RE1      ; ativar ENABLE do LCD
    bcf PORTE, RE1      ; Desativar ENABLE do LCD
    call atraso_lcd
    return
 
escreve_dado_lcd
    bsf PORTE, RE0      ; Define dado no LCD(RS=1)
    movwf PORTD
    bsf PORTE, RE1      ; ativar ENABLE do LCD
    bcf PORTE, RE1      ; Desativar ENABLE do LCD
    call atraso_lcd
    return
 
atraso_lcd      ; Atraso de 40us para LCD
    movlw 26        ;8clocks (pq ele deu um call ent„o zero... comeÁo do 0... o segundo ja È 4 clocks)
    movwf contador  ; 4 clocks
ret_atraso_lcd
    decfsz contador ; 8 clocks (qndo da saltos È 8 clocks), este e o goto vai ser repetido N vezes
    goto ret_atraso_lcd ; 4 clocks
    return
 
atraso_limpa_lcd
    movlw 40        ;8clocks (pq ele deu um call ent„o zero... comeÁo do 0... o segundo ja È 4 clocks)
    movwf contador2 ; 4 clocks
ret_atraso_limpa_lcd
    call atraso_lcd
    decfsz contador2    
    goto ret_atraso_limpa_lcd   
    return
    
;------------ BUZZER DE ENTRADA ------------------  
buzz
    BANCO1
    movlw b'00000000' ;	config a porta RA5/AN4 como saida digital (afeta as outras)
    movwf TRISA
    BANCO0
    
buzz_0
    movlw .20
    movwf contador_buzz
toca_buzz
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    bsf PORTA, 5
    call atraso_limpa_lcd
    bcf PORTA, 5
    call atraso_limpa_lcd
    decfsz contador_buzz
    goto toca_buzz
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    call espera_0.5s
    btfsc n2
    goto valor_entrada_2     
    btfsc n5
    goto valor_entrada_5
    call espera_0.5s
    goto buzz_0
    
;------------ BUZZER DE SAÕDA ------------------  
buzz_saida
    BANCO1
    movlw b'00000111' ;	config a porta RA5/AN4 como saida digital (afeta as outras)
    movwf TRISA
    BANCO0
    
buzz_1
    movlw .20
    movwf contador_buzz
toca_buzz_saida
    bsf ADCON0, GO_DONE		  ;set bit 2 do adcon0 (GO/DONE)
volta_sensores_ativado_buzz
    btfsc ADCON0, GO_DONE
    goto volta_sensores_ativado_buzz

    bsf PORTA, 5
    call atraso_limpa_lcd
    bcf PORTA, 5
    call atraso_limpa_lcd
    
    movfw ADRESH
    movwf peso_veiculo

    movlw .180
    subwf peso_veiculo, W
    btfss STATUS, C
    goto fechar_cancela
    decfsz contador_buzz
    goto toca_buzz_saida
    call espera_1s
    goto buzz_1
    
 end