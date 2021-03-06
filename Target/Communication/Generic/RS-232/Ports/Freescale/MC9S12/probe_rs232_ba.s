;********************************************************************************************************
;*                                       uC/Probe Communication
;*
;*                    Copyright 2007-2020 Silicon Laboratories Inc. www.silabs.com
;*
;*                                 SPDX-License-Identifier: APACHE-2.0
;*
;*               This software is subject to an open source license and is distributed by
;*                Silicon Laboratories Inc. pursuant to the terms of the Apache License,
;*                    Version 2.0 available at www.apache.org/licenses/LICENSE-2.0.
;*
;********************************************************************************************************

;********************************************************************************************************
;                                       PAGED S12X Specific code
;                                            (CODEWARRIOR)
;
; File  : probe_rs232_ba.s
; Notes : THIS FILE *MUST* BE LINKED INTO NON_BANKED MEMORY!
;********************************************************************************************************

NON_BANKED:       section


;********************************************************************************************************
;                                           I/O PORT ADDRESSES
;********************************************************************************************************

PPAGE:            equ    $0030         ; Addres of PPAGE register (Assuming MC9S12DP256)


;********************************************************************************************************
;                                          PUBLIC DECLARATIONS
;********************************************************************************************************

    xdef   ProbeRS232_RxTxISR


;********************************************************************************************************
;                                         EXTERNAL DECLARATIONS
;********************************************************************************************************

    xref   OSIntExit
    xref   OSIntNesting
    xref   OSTCBCur

    xref   ProbeRS232_RxTxISRHandler


;********************************************************************************************************
;                                           uC/Probe Rx ISR
;
; Description : This routine is the uC/Probe Rx interrupt service routine
;
; Arguments   : none
;
; Notes       : 1) All USER interrupts should be modeled EXACTLY like this where the only
;                  line to be modified is the call to your ISR_Handler and perhaps the call to
;                  the label name ProbeRS232_RxISRHandler.
;********************************************************************************************************

ProbeRS232_RxTxISR:
    ldaa   PPAGE                       ; Get current value of PPAGE register
    psha                               ; Push PPAGE register onto current task's stack

    inc    OSIntNesting                ; Notify uC/OS-II about ISR

    ldab   OSIntNesting                ; if (OSIntNesting == 1) {
    cmpb   #$01
    bne    ProbeRS232_RxTxISR1

    ldy    OSTCBCur                    ;     OSTCBCur->OSTCBStkPtr = Stack Pointer
    sts    0,y                         ; }


ProbeRS232_RxTxISR1:
    call   ProbeRS232_RxTxISRHandler  ; Call Rx ISR handler. (See probe_rs232c.c)

;   cli                               ; Optionally enable interrupts to allow interrupt nesting

    call   OSIntExit                  ; Notify uC/OS-II about end of ISR, a context switch may occur from within OSIntExit().

    pula                               ; Get value of PPAGE register
    staa   PPAGE                       ; Store into CPU's PPAGE register

    rti                               ; Return from interrupt to interrupted task.


