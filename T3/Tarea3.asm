name "Tarea3"

#start=Interruptor.exe#
#start=robot.exe#

org 100h

start:  
        MOV AX, 0       
        MOV ES, AX
        MOV AL, 90H ; EN LA DIRECCION 0X90 DEL VECTOR DE INTERRUPCIONES   
        MOV BL, 4H       
        MUL BL          
        MOV BX, AX
        MOV SI, OFFSET [boton_1] ;REFERENCIAMOS LA ISR BOTON_1
        MOV ES:[BX], SI
        ADD BX, 2                                              
        MOV AX, CS     
        MOV ES:[BX], AX
             
        MOV AX, 0       
        MOV ES, AX
        MOV AL, 91H ; EN LA DIRECCION 0X91 DEL VECTOR DE INTERRUPCIONES   
        MOV BL, 4H       
        MUL BL          
        MOV BX, AX
        MOV SI, OFFSET [boton_2] ;REFERENCIAMOS LA ISR BOTON_2
        MOV ES:[BX], SI
        ADD BX, 2   
        MOV AX, CS     
        MOV ES:[BX], AX
          
        MOV AX, 0       
        MOV ES, AX
        MOV AL, 92H ; EN LA DIRECCION 0X92 DEL VECTOR DE INTERRUPCIONES   
        MOV BL, 4H       
        MUL BL          
        MOV BX, AX
        MOV SI, OFFSET [boton_3] ;REFERENCIAMOS LA ISR BOTON_3
        MOV ES:[BX], SI
        ADD BX, 2   
        MOV AX, CS     
        MOV ES:[BX], AX
        
        ;Completar Programa

        JMP waiting

checktime:  ;Ejecuta la subrutina A
        
        CALL A              ;Llamada a la subrutina A (sin params)
        MOV [time], AL      ;Almacenar retorno
        MOV [current], 0    ;Volver al estado de espera
        JMP waiting         ;Volver al ciclo de espera      

showtime:   ;Ejecuta la subrutina B

        MOV BL, [time]      ;Se pasa el parametro del tiempo en horas
	    PUSH BX
        CALL B              ;Llamada a la subrutina B (1 param)
        MOV [current], 0    ;Volver al estado de espera 
        JMP waiting         ;Volver al ciclo de espera    

robot:      ;Ejecuta la subrutina C
        
        CALL C              ;Llamada a la subrutina C (sin params)
        MOV [current], 0    ;Volver al estado de espera (Inalcanzable) 
        JMP waiting         ;Volver al ciclo de espera (Inalcanzable) 

waiting:    ;Esperar interrupciones
        
        CMP [current], 0    ;Revisa si NO se han ejecutado ISR
        JE waiting

execute:    ;Ejecuta las acciones asociadas a la ultima interrupcion registrada en 'waiting'

        CMP [current], 2    ;Revisa la ultima interrupcion atendida
        JB checktime        ;Boton 1
        JE showtime         ;Boton 2
        JA robot            ;Boton 3
        RET                 ;Fin del programa (Inalcanzable)     

; Declarar variables
 
current      DB 0        ;Valor asociado a la interrupcion actual

time         DB 0        ;Tiempo desde la medianoche (por default es 0)

direction    DB 3        ;Mano dominante del robot (diestro es 3, zurdo es 2)

      ;Agregar Subrutinas
    
      A:    ;Calcula la cantidad de horas desde la medianoche
              
              PUSH BP           ;Cargar SP en BP
              MOV BP, SP       
              MOV AH, 0         ;AH = 00h
              INT 1Ah           ;Obtiene los ciclos de clock desde la medianoche
              MOV AX, DX        ;Copiar los valores a los registros usados en la division
              MOV DX, CX        
              MOV CX, 1092      ;Aprox. 1092 ciclos de clock por minuto
              DIV CX            ;Minutos transcurridos desde la medianoche (en AX)
              MOV DL, 60        ;Se divide por 60 para obtener las horas
              DIV DL            ;Horas transcurridas desde la medianoche (en AL)
              MOV AH, 0         ;Asegurar que AX tiene el mismo valor que AL
              POP BP            ;Restaurar el BP             
              RET               ;Retornar (no se usaron params) (resultado en AX) 
              
      B:    ;Muestra la cantidad de horas actual en la interfaz
         
              PUSH BP       	;Cargar SP en BP
              MOV BP, SP 
              MOV AH, 0
              MOV AL, [BP + 4]  ;Recuperar cantidad de horas
              MOV DL, 10 
              DIV DL            ;Dividir por 10 para obtener el 1er digito decimal
              ADD AL, 48        ;Sumarle 48 para obtener el caracter Ascii
              MOV DL, AH        ;Guardar el modulo de la division para el segundo digito
	          MOV AH, 0Eh       ;AH = 0Eh
	          INT 10h           ;Mostrar en la interfaz el 1er digito
              MOV AL, DL        ;2do digito (modulo de la division)
              ADD AL, 48        ;Sumarle 48 para obtener el caracter Ascii
              INT 10h           ;Mostrar en la interfaz el 2do digito
              POP BP        	;Restaurar el BP
              RET 2         	;Mover SP y retornar (1 param)

      C:    ;Simula las acciones del robot
              
              PUSH BP           ;Cargar SP en BP
              MOV BP, SP
      
      simulate: ;Simula una accion del robot        
      
              CALL waitcommand  ;No hacer nada (permite repetir acciones)
              MOV AL, 0
              OUT 9, AL
              CALL waitcommand  ;Esperar a que este disponible
              MOV AL, 4         ;Examinar
              OUT 9, AL  
              CALL waitdata     ;Esperar a que termine de examinar       
              IN AL, 10         ;Datos obtenidos
              CMP AL, 0         ;Revisa si el camino esta libre
              JE forward        ;Camino esta libre
              CMP AL, 8         ;Revisa el tipo de obstaculo
              JB electrocute    ;Bombilla encendida
              JE annoyed        ;Bombilla apagada
              JA wall           ;Muro
              POP BP            ;Restaurar el BP (Inalcanzable)
              RET               ;Retornar (Inalcanzable)
              
      waitcommand:  ;Espera a que el robot este disponible
              
              MOV CX, 0
              
        waitdelay:  ;Delay para que el robot no se comporte de forma irregular
              
              INC CX            ;*** Delay ajustado para 0 ms ***
              CMP CX, 5         ;*** En esta linea se puede modificar el DELAY *** 
              JB waitdelay      ;*** Disminuir el num del CMP para velocidades mas lentas ***
                                ;*** Conf.Recomendada: 0 ms => 5, 1 ms => 2, otros => 0 *** 
        
        waitloop:
        
              IN AL, 11  
              AND AL, 10b
              JNE waitloop
              RET
                      
      waitdata:     ;Espera a que el robot haya terminado de examinar
 
              MOV CX, 0
              
        datadelay:  ;Delay para que el robot no se comporte de forma irregular
              
              INC CX            ;*** Delay ajustado para 0 ms ***
              CMP CX, 5         ;*** En esta linea se puede modificar el DELAY ***
              JB datadelay      ;*** Disminuir el num del CMP para velocidades mas lentas ***
                                ;*** Conf.Recomendada: 0 ms => 5, 1 ms => 2, otros => 0 ***
        
        dataloop:
      
              IN AL, 11  
              AND AL, 01b
              JE dataloop
              RET

      turn:         ;Da un giro segun su mano dominante
              
              PUSH BP           ;Cargar SP en BP
              MOV BP, SP
              CALL waitcommand  ;Esperar a que este disponible
              MOV AL, [BP + 4]  ;Recuperar la mano dominante
              OUT 9, AL         ;Girar
              POP BP            ;Restaurar el BP
              RET 2         	;Mover SP y retornar (1 param)
           
      forward:      ;Se mueve hacia adelante
      
              CALL waitcommand  ;Esperar a que este disponible
              MOV AL, 1
              OUT 9, AL
              JMP simulate 
      
      electrocute:  ;Se electrocuta, apaga la bombilla y da un giro
      
              CALL waitcommand  ;Esperar a que este disponible
              MOV AL, 6         ;Apaga la bombilla
              OUT 9, AL 
              MOV DL, 2
              CMP [direction], 3
              JE change
              MOV DL, 3

      change:       ;Cambia la mano dominante
              
              MOV [direction], DL
	          PUSH DX           ;Se pasa el parametro de la mano dominante
              CALL turn
              JMP simulate

      annoyed:      ;Se molesta y se da media vuelta
              
              MOV DL, [direction]
	          PUSH DX           ;Se pasa el parametro de la mano dominante
              CALL turn
              CALL waitcommand
              MOV AL, 0         ;No hacer nada (permite repetir acciones)
              OUT 9, AL
              MOV DL, [direction]
	          PUSH DX           ;Se pasa el parametro de la mano dominante
              CALL turn
              JMP simulate
      
      wall:         ;Da un giro si ve una pared
      
              MOV DL, [direction]
	          PUSH DX           ;Se pasa el parametro de la mano dominante
              CALL turn
              JMP simulate

      boton_1:
              ;Completar Codigo ISR
              
              PUSHA             ;Backup de los registros         
              MOV [current], 1  ;Se guarda el valor asociado a la interrupcion
              MOV AL, 20h       ;EOI al PIC1 (asumiendo que los botones pasan por el)
              OUT 20h, AL   
              POPA              ;Restaurar los registros 
              IRET
              
      boton_2:
              ;Completar Codigo ISR
              
              PUSHA             ;Backup de los registros
              MOV [current], 2  ;Se guarda el valor asociado a la interrupcion
              MOV AL, 20h       ;EOI al PIC1 (asumiendo que los botones pasan por el)
              OUT 20h, AL   
              POPA              ;Restaurar los registros
              IRET
      
      boton_3:
              ;Completar Codigo ISR
              
              PUSHA             ;Backup de los registros
              MOV [current], 3  ;Se guarda el valor asociado a la interrupcion
              MOV AL, 20h       ;EOI al PIC1 (asumiendo que los botones pasan por el)
              OUT 20h, AL   
              POPA              ;Restaurar los registros
              IRET