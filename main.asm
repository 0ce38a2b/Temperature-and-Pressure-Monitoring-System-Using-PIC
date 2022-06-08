; This assembly code is loaded into the PIC micro-controller

; Do not use this in production. Sample purpose only.

; Author: 0ce38a2b

#include <p16F877A.inc>
; CONFIG
__config 0xFF32
;__CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

org    	0x00
TEMP

;0x35 ADC result for temperature
;0x55 ADC result for preasure

;0x30 is used also for storing ADC temperature result
;0x50 is used also for storing ADC preasure result

;0x41,0x42,0x43 Division variable 

;0x45 is  the final port signal for temperature
;0x65 is  the final port signal for preasure

GOTO INITIALIZE

INITIALIZE
			;Initialize the PORTS
			bsf STATUS, 5       ;Switch to Bank 1
			bsf TRISE,0         ;set RA0 as input pin
			bsf TRISE,1         ;set RA1 as input pin
			clrf TRISA          ;set all PORTA pins as outputs
			clrf TRISB          ;set all PORTB pins as outputs
            movlw B'00110000'   ;set all PORTC 4,5 pins as inputs
            movwf TRISC         ;set PORTC 0-3,6,7 pins as outputs
			clrf TRISD          ;set all PORTD pins as outputs
			
			;Initialize the ADC
			movlw b'00000000'    ;VREF = VDD(connected with supply)
			movwf ADCON1         ;RE0,1(AN5,AN6) analog
			
			;Initialize Intrupts
			;bsf INTCON,T0IE     ;enable timer0 interrupt
			bsf INTCON,GIE       ;enable Golbal Inerrupt
            
            ;Initialize Timer0 to perform delay
            MOVLW 0x87			 ;setting TMR0 prescaller to 1:125
            MOVWF OPTION_REG     ;TMR0 in timer mode, clock source from Focs/4
  			bcf STATUS, 5        ;Switch to Bank 0

MAIN 
			CALL REAR_AND_DISPLAY_TEMP
			CALL DELAY
			CALL REAR_AND_DISPLAY_PRESSURE
			
			BCF PORTC,6
			BCF PORTC,7
										
			BTFSC PORTC,4                ; test RC4(TEMP), skip next instruction if it is "0"
			CALL SET_HIGH_TEMP_ALARM     ; send high temperature signal
			BTFSC PORTC,5                ; test RC5,(PREASURE) skip next instruction if it is "0"
			CALL SET_HIGH_PREASURE_ALARM ; send high preasure signal
			GOTO MAIN

REAR_AND_DISPLAY_TEMP
							;****Configure ADC****
							movlw b'01101001'    ;select channel 5(AN5) as the input of the ADC (CHS2:CHS0 == 101)
							movwf ADCON0         ;FOSC/8(conversion clock source), enable A/D
					
					        call DELAY
					       
							bsf ADCON0,GO         ;initiate ADC conversion
							conversion_check      ;check if the conversion is done?
							btfsc ADCON0,GO       ;conversion done? if done, skip next
							goto conversion_check ;not finished
							
							banksel ADCON0     	  ;select bank for the result part
							rlf  ADRESH,F         ;Here the temperature value is at max 150 so no need of the 10th bit as than 255 but
							btfsc ADRESL,7        ;it considered if the ADC value is  more in our case wont happen
							bsf  ADRESH,0         ;The ADRES's last bit is least significant bit.So we dont consider it valid and avoid it.
							movf ADRESH,w         ;Now we only need the 8 bits of the 10 bit ADC Result. So we are extracting the result as per
							movwf 0x35            ;0x35 ADC result for temperature
					        movwf 0x30            ;temporary storage for tepm, result is stored in a temporary location
						 
							movlw 0x00            ;This register is used for  directly storing the 3bit decimal number
							movf  0x45            ;It this register only the MSB 2 and 1 bits are stored
							
							movlw b'01100100'     ;extracting hundreds place, 100
							
							subwf 0x35,f          ;f=f-w   ie f=f-100
							
							btfsc STATUS,C
							goto setONE
							goto setZERO
							
							setONE:
							movlw b'00010000'
							movwf 0x45
							goto NEXT
							
							setZERO:
							movf 0x30,w
							movwf 0x35
							movlw b'00000000'
							movwf 0x45
							goto  NEXT
							
							NEXT:                   ;extracting 10's place
							movlw 0x0A
							movwf 0x41
									
							clrf 0x42               ;Division Algorithm
							MOVF 0X41,W             ;Division  0x35/0x41  ie value/10, and 0x42 will serve as quotient
							LP1:
							incf 0x42,f
							SUBWF 0X35,F
							BTFSC STATUS,C
							GOTO LP1
							
							movlw 0x01              ;quotient
							subwf 0x42,f
							
							movf 0x41,w             ;remainder
							addwf 0x35,f
							
							movf 0x42,w
							iorwf 0x45,f
							
							movf 0x35,w             ;extract the one's place digit to 0x35
							movwf PORTC             ;send result to PORTC
							movf 0x45,w
							movwf PORTB             ;send result to PORTB
                            RETURN

REAR_AND_DISPLAY_PRESSURE
							;****Configure ADC****
							movlw b'01110001'       ;(CHS2:CHS0 == 001)
							movwf ADCON0            ; select channel 6(AN6), FOSC/8(conversion clock source), enable A/D
							
							call DELAY              ;Time for Tad
					
							bsf ADCON0,GO           ;initiate conversion
							conversion_check_2 	    ;check if the conversion is done?
							btfsc ADCON0,GO         ;conversion done? if done, skip next
							goto conversion_check_2 ;not finished
							
							banksel ADRESH          ;select bank for result part
							rlf  ADRESH,F           ;F: store the result in the file register
							
							btfsc ADRESL,7
							bsf  ADRESH,0
							
							movf ADRESH,w
							
							movwf 0x55              ;0x55 ADC result for preasure
							movwf 0x50              ;temporary storage for preasure
							
							movlw 0x00              ;this register is used for  directly storing the 3bit decimal number 
							movf  0x65              ;It this register only the MSB 2 and 1 bits are stored
							
							movlw b'01001100'       ;100 ;extracting hundreds place
							subwf 0x55,f            ;f=f-w,f=f-100
							
							btfsc STATUS,C
							goto setONE_2
							goto setZERO_2
							
							setONE_2:
							movlw b'00010000'
							movwf 0x65
							goto NEXT_2
							
							setZERO_2:
							movf 0x50,w
							movwf 0x55
							movlw b'00000000'
							movwf 0x65
							goto  NEXT_2
					
							
							NEXT_2:                  ;extracting 10's place
							movlw 0x0A
							movwf 0x41
							
							clrf 0x42
							MOVF 0X41,W
							LP1_2:
							incf 0x42,f
							SUBWF 0X55,F
							BTFSC STATUS,C
							GOTO LP1_2
							
							movlw 0x01               ;quotient
							subwf 0x42,f
							
							movf 0x41,w              ;remainder
							addwf 0x55,f
							
							movf 0x42,w
							iorwf 0x65,f
							
							movfw 0x55               ;extract the one's place digit to 0x55
							movwf PORTA              ;send result to PORTA
							movf 0x65,w
							movwf PORTD              ;send result to PORTD
                            RETURN



SET_HIGH_TEMP_ALARM BSF PORTC,6
                    CALL DELAY
                    RETURN

SET_HIGH_PREASURE_ALARM BSF PORTC,7   
                        CALL DELAY                   
                        RETURN

DELAY     MOVLW 0x01
 		  MOVWF TEMP
          CLRF TMR0
OUTER_LOOP BCF INTCON,T0IF
INNER_LOOP BTFSS INTCON,T0IF
 	       GOTO INNER_LOOP
	       DECFSZ TEMP,F
	       GOTO OUTER_LOOP
	       RETURN


end
