.MODEL SMALL
.STACK 200H
.DATA
    MAX_PRODUCTS    EQU 10

    ProdIDs         DW  MAX_PRODUCTS DUP(0)
    ProdNames       DB  MAX_PRODUCTS * 20 DUP('$')
    ProdCats        DB  MAX_PRODUCTS * 10 DUP('$')
    ProdPrices      DW  MAX_PRODUCTS DUP(0)
    ProdQtys        DW  MAX_PRODUCTS DUP(0)
    ProdSIDPtrs     DW  MAX_PRODUCTS DUP(0)

    MAX_SUPPLIERS   EQU 5

    SuppIDs         DW  MAX_SUPPLIERS DUP(0)
    SuppContacts    DB  MAX_SUPPLIERS * 12 DUP('$')
    SuppStatus      DB  MAX_SUPPLIERS DUP(00h)

    XOR_KEY         DB  0AAh

    ADMIN_PASS      DB  'admin', '$'
    ADMIN_PASS_LEN  EQU 5

    SUPP_PASS       DB  'supp', '$'
    SUPP_PASS_LEN   EQU 4

    CURRENT_SID     DW  0

    TEMP_ID         DW  0
    TEMP_PRICE      DW  0
    TEMP_QTY        DW  0
    TEMP_SID        DW  0
    SEARCH_ID       DW  0

    TOTAL_VAL_LOW   DW  0
    TOTAL_VAL_HIGH  DW  0

    NAME_BUFFER     DB  20, ?, 21 DUP(' ')
    CAT_BUFFER      DB  10, ?, 11 DUP(' ')
    PASS_BUFFER     DB  10, ?, 11 DUP(' ')
    CONT_BUFFER     DB  12, ?, 13 DUP(' ')

    NEWLINE         DB  0Dh, 0Ah, '$'
    SPACE3          DB  '   $'
    SPACE2          DB  '  $'

   
    MSG_BORDER      DB  '========================================$'
    MSG_TITLE       DB  ' Smart Inventory Sys 8086 $'
    MSG_GATE_1      DB  '1. Admin Login$'
    MSG_GATE_2      DB  '2. Supplier Login$'
    MSG_GATE_3      DB  '3. User View (Read-Only)$'
    MSG_GATE_4      DB  '4. Exit Program$'
    MSG_CHOICE      DB  'Enter Choice: $'
    MSG_INVALID     DB  'Invalid Choice! Try again.$'
    MSG_ENTER_PASS  DB  'Enter Passcode: $'
    MSG_LOGIN_OK    DB  'Access Granted!$'
    MSG_WRONG_PASS  DB  'Access Denied! Wrong Passcode.$'
    PROMPT_SID      DB  'Enter Your Supplier ID: $'

    MSG_ADMIN_TITLE DB  'ADMIN MENU$'
    MSG_ADM_1       DB  '1. View All Products$'
    MSG_ADM_2       DB  '2. Add New Product$'
    MSG_ADM_3       DB  '3. Restock Product$'
    MSG_ADM_4       DB  '4. Sell Product$'
    MSG_ADM_5       DB  '5. Search Product$'
    MSG_ADM_6       DB  '6. Total Inventory Value$'
    MSG_ADM_7       DB  '7. Low Stock Alert$'
    MSG_ADM_8       DB  '8. Manage Suppliers$'
    MSG_ADM_0       DB  '0. Logout$'

    MSG_SUPP_TITLE  DB  '--- SUPPLIER MENU ---$'
    MSG_SUPP_1      DB  '1. View My Products$'
    MSG_SUPP_2      DB  '2. Restock My Product$'
    MSG_SUPP_0      DB  '0. Logout$'

    MSG_USER_TITLE  DB  '--- USER VIEW (Read-Only) ---$'
    MSG_USER_1      DB  '1. View All Products$'
    MSG_USER_2      DB  '2. Search Product$'
    MSG_USER_0      DB  '0. Logout$'

    MSG_PROD_HDR    DB  'ID  Name                Cat        Price  Qty  SuppID$'
    MSG_SEPARATOR   DB  '-----------------------------------------------------$'

    PROMPT_ID       DB  'Enter Product ID (1-99): $'
    PROMPT_NAME     DB  'Enter Name (Max 19 chars): $'
    PROMPT_CAT      DB  'Enter Category (Max 9 chars): $'
    PROMPT_PRICE    DB  'Enter Price: $'
    PROMPT_QTY      DB  'Enter Quantity: $'
    PROMPT_CONT     DB  'Enter Contact No (Max 11 chars): $'

    MSG_PROD_FULL   DB  'Inventory Full!$'
    MSG_PROD_ADDED  DB  'Product Added Successfully!$'
    MSG_PROD_EXISTS DB  'Error: Product ID already exists!$'
    MSG_NOT_FOUND   DB  'Item not found!$'
    MSG_RESTOCKED   DB  'Restock Successful!$'
    MSG_SOLD        DB  'Sale Recorded!$'
    MSG_NO_STOCK    DB  'Not enough stock!$'
    MSG_OVERFLOW    DB  'Warning: Stock overflow prevented!$'
    MSG_TOTAL_LBL   DB  'Total Inventory Value: $'
    MSG_LOW_HDR     DB  'LOW STOCK ALERT$'
    MSG_SEARCH_PMPT DB  'Search by: 1.ID  2.Name: $'

    MSG_SUPP_MNGR   DB  '--- SUPPLIER MANAGEMENT ---$'
    MSG_SUPP_MA     DB  '1. View All Suppliers$'
    MSG_SUPP_MB     DB  '2. Add New Supplier$'
    MSG_SUPP_MC     DB  '0. Back to Admin Menu$'
    MSG_SUPP_HDR    DB  'SID  Contact        Status$'
    MSG_SUPP_ADDED  DB  'Supplier Added!$'
    MSG_SUPP_FULL   DB  'Supplier List Full!$'
    MSG_ACTIVE      DB  'Active  $'
    MSG_INACTIVE    DB  'Inactive$'

.CODE
    DISPLAY_STR MACRO STR_LABEL
        PUSH AX
        PUSH DX
        LEA  DX, STR_LABEL
        MOV  AH, 09H
        INT  21H
        POP  DX
        POP  AX
    ENDM

    ; Print CR+LF
    WZ_NEWLINE MACRO
        PUSH AX
        PUSH DX
        LEA  DX, NEWLINE
        MOV  AH, 09H
        INT  21H
        POP  DX
        POP  AX
    ENDM

    PRINT_CHAR MACRO CHAR
        PUSH AX
        PUSH DX
        MOV  DL, CHAR
        MOV  AH, 02H
        INT  21H
        POP  DX
        POP  AX
    ENDM

    CLEAR_SCREEN MACRO
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        MOV  AH, 06H
        MOV  AL, 00H
        MOV  BH, 07H
        MOV  CX, 0000H
        MOV  DX, 184FH
        INT  10H
        MOV  AH, 02H
        MOV  BH, 00H
        MOV  DH, 00H
        MOV  DL, 00H
        INT  10H
        POP  DX
        POP  CX
        POP  BX
        POP  AX
    ENDM

    MAIN PROC
        MOV  AX, @DATA
        MOV  DS, AX
        MOV  ES, AX
        CALL ENCRYPT_PASSES

    RESTART_GATE:
        CLEAR_SCREEN
        CALL AUTH_JUMP_TABLE
        JMP  RESTART_GATE

    MAIN ENDP

    AUTH_JUMP_TABLE PROC
    GATE_LOOP:
        CLEAR_SCREEN
        WZ_NEWLINE
        DISPLAY_STR MSG_BORDER
        WZ_NEWLINE
        DISPLAY_STR MSG_TITLE
        WZ_NEWLINE
        DISPLAY_STR MSG_BORDER
        WZ_NEWLINE
        WZ_NEWLINE
        DISPLAY_STR MSG_GATE_1
        WZ_NEWLINE
        DISPLAY_STR MSG_GATE_2
        WZ_NEWLINE
        DISPLAY_STR MSG_GATE_3
        WZ_NEWLINE
        DISPLAY_STR MSG_GATE_4
        WZ_NEWLINE
        DISPLAY_STR MSG_CHOICE

        MOV  AH, 01H 
        INT  21H
        MOV  BL, AL

        MOV  AH, 01H
        INT  21H

        CMP  BL, '1'
        JE   GATE_TO_ADMIN
        CMP  BL, '2'
        JE   GATE_TO_SUPP
        CMP  BL, '3'
        JE   GATE_TO_USER
        CMP  BL, '4'
        JE   GATE_EXIT

        WZ_NEWLINE
        DISPLAY_STR MSG_INVALID
        JMP  GATE_LOOP

    GATE_TO_ADMIN:
        CALL VERIFY_ADMIN_PASS
        CMP  AX, 1
        JNE  GATE_LOOP
        CALL ADMIN_MENU
        JMP  GATE_LOOP

    GATE_TO_SUPP:
        CALL VERIFY_SUPP_PASS
        CMP  AX, 1
        JNE  GATE_LOOP
        CALL SUPPLIER_MENU
        JMP  GATE_LOOP

    GATE_TO_USER:
        CALL USER_MENU
        JMP  GATE_LOOP

    GATE_EXIT:
        MOV  AX, 4C00H
        INT  21H
    AUTH_JUMP_TABLE ENDP

    ENCRYPT_PASSES PROC
        PUSH AX
        PUSH CX
        PUSH SI

        MOV  CX, ADMIN_PASS_LEN
        LEA  SI, ADMIN_PASS

    ENC_ADMIN_LOOP:
        MOV  AL, [SI]
        XOR  AL, XOR_KEY
        MOV  [SI], AL
        INC  SI
        LOOP ENC_ADMIN_LOOP

        MOV  CX, SUPP_PASS_LEN
        LEA  SI, SUPP_PASS

    ENC_SUPP_LOOP:
        MOV  AL, [SI]
        XOR  AL, XOR_KEY
        MOV  [SI], AL
        INC  SI
        LOOP ENC_SUPP_LOOP

        POP  SI
        POP  CX
        POP  AX
        RET
    ENCRYPT_PASSES ENDP

 VERIFY_ADMIN_PASS PROC
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    WZ_NEWLINE
    DISPLAY_STR MSG_ENTER_PASS
    
    LEA DX, PASS_BUFFER
    MOV AH, 0AH
    INT 21H
    
    LEA SI, PASS_BUFFER + 2
    LEA DI, ADMIN_PASS

CMP_ADMIN_LOOP:
    MOV AL, [SI]
    CMP AL, 0DH
    JE ADMIN_CHK_END
    
    MOV AH, [DI]
    CMP AH, '$'
    JE ADMIN_FAIL
    
    XOR AH, XOR_KEY
    CMP AL, AH
    JNE ADMIN_FAIL
    
    INC SI
    INC DI
    JMP CMP_ADMIN_LOOP

ADMIN_CHK_END:
    MOV AH, [DI]
    CMP AH, '$'
    JNE ADMIN_FAIL
    
    WZ_NEWLINE
    DISPLAY_STR MSG_LOGIN_OK
    MOV AX, 1
    JMP ADMIN_PASS_RET

ADMIN_FAIL:
    WZ_NEWLINE
    DISPLAY_STR MSG_WRONG_PASS
    MOV AX, 0

ADMIN_PASS_RET:
    POP DI
    POP SI
    POP CX
    POP BX
    RET
VERIFY_ADMIN_PASS ENDP



  VERIFY_SUPP_PASS PROC
       PUSH BX
       PUSH CX
       PUSH SI
       PUSH DI
       WZ_NEWLINE
       DISPLAY_STR MSG_ENTER_PASS
       LEA  DX, PASS_BUFFER
       MOV  AH, 0AH
       INT  21H
       LEA  SI, PASS_BUFFER + 2
       LEA  DI, SUPP_PASS
   CMP_SUPP_LOOP:
       MOV  AL, [SI]
      
       CMP  AL, 0DH
       JE   SUPP_CHK_END
       MOV  AH, [DI]
       CMP  AH, '$'
       JE   SUPP_FAIL
       XOR  AH, XOR_KEY 
       CMP  AL, AH
       JNE  SUPP_FAIL
       INC  SI
       INC  DI
       JMP  CMP_SUPP_LOOP
   SUPP_CHK_END:
       MOV  AH, [DI]
       CMP  AH, '$'
       JNE  SUPP_FAIL
       WZ_NEWLINE
       DISPLAY_STR PROMPT_SID
       CALL READ_NUM
       MOV  CURRENT_SID, AX
       WZ_NEWLINE
       DISPLAY_STR MSG_LOGIN_OK
       MOV  AX, 1
       JMP  SUPP_PASS_RET
   SUPP_FAIL:
       WZ_NEWLINE
       DISPLAY_STR MSG_WRONG_PASS
       MOV  AX, 0
   SUPP_PASS_RET:
       POP  DI
       POP  SI
       POP  CX
       POP  BX
       RET
   VERIFY_SUPP_PASS ENDP



ADMIN_MENU PROC
ADMIN_LOOP:
    CLEAR_SCREEN
    WZ_NEWLINE
    DISPLAY_STR MSG_BORDER
    WZ_NEWLINE
    DISPLAY_STR MSG_ADMIN_TITLE
    WZ_NEWLINE
    DISPLAY_STR MSG_BORDER
    WZ_NEWLINE
    DISPLAY_STR MSG_ADM_1
    WZ_NEWLINE
    DISPLAY_STR MSG_ADM_2
    WZ_NEWLINE
    DISPLAY_STR MSG_ADM_3
    WZ_NEWLINE
    DISPLAY_STR MSG_ADM_4
    WZ_NEWLINE
    DISPLAY_STR MSG_ADM_5
    WZ_NEWLINE
    DISPLAY_STR MSG_ADM_6
    WZ_NEWLINE
    DISPLAY_STR MSG_ADM_7
    WZ_NEWLINE
    DISPLAY_STR MSG_ADM_8
    WZ_NEWLINE
    DISPLAY_STR MSG_ADM_0
    WZ_NEWLINE
    DISPLAY_STR MSG_CHOICE

    MOV  AH, 01H
    INT  21H
    MOV  BL, AL

    MOV  AH, 01H
    INT  21H

    MOV  AL, BL
    SUB  AL, 30H
    XOR  AH, AH

    CMP  AX, 1
    JE   ADM_DO_VIEW
    CMP  AX, 2
    JE   ADM_DO_ADD
    CMP  AX, 3
    JE   ADM_DO_RESTOCK
    CMP  AX, 4
    JE   ADM_DO_SELL
    CMP  AX, 5
    JE   ADM_DO_SEARCH
    CMP  AX, 6
    JE   ADM_DO_TOTAL
    CMP  AX, 7
    JE   ADM_DO_LOW
    CMP  AX, 8
    JE   ADM_DO_SUPP

    CMP  BL, '0'
    JE   ADM_LOGOUT

    WZ_NEWLINE
    DISPLAY_STR MSG_INVALID
    JMP  ADMIN_LOOP

ADM_DO_VIEW:
    CALL VIEW_PRODUCTS
    JMP  ADMIN_LOOP

ADM_DO_ADD:
    CALL ADD_PRODUCT
    JMP  ADMIN_LOOP

ADM_DO_RESTOCK:
    CALL RESTOCK_PRODUCT
    JMP  ADMIN_LOOP

ADM_DO_SELL:
    CALL SELL_PRODUCT
    JMP  ADMIN_LOOP

ADM_DO_SEARCH:
    CALL SEARCH_ITEM
    JMP  ADMIN_LOOP

ADM_DO_TOTAL:
    CALL CALC_TOTAL_VALUE
    JMP  ADMIN_LOOP

ADM_DO_LOW:
    CALL LOW_STOCK_ALERT
    JMP  ADMIN_LOOP

ADM_DO_SUPP:
    CALL MANAGE_SUPPLIERS
    JMP  ADMIN_LOOP

ADM_LOGOUT:
    RET
ADMIN_MENU ENDP

VIEW_PRODUCTS PROC
    WZ_NEWLINE
    DISPLAY_STR MSG_PROD_HDR
    WZ_NEWLINE
    DISPLAY_STR MSG_SEPARATOR
    WZ_NEWLINE

    MOV  CX, MAX_PRODUCTS
    MOV  SI, 0
    MOV  DI, 0
    MOV  BX, 0

VIEW_LOOP:
    MOV  AX, ProdIDs[SI]
    CMP  AX, 0
    JE   VIEW_SKIP

    MOV  AX, ProdIDs[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    LEA  DX, ProdNames[DI]
    MOV  AH, 09H
    INT  21H
    DISPLAY_STR SPACE2

    LEA  DX, ProdCats[BX]
    MOV  AH, 09H
    INT  21H
    DISPLAY_STR SPACE2

    MOV  AX, ProdPrices[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    MOV  AX, ProdQtys[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    MOV  AX, ProdSIDPtrs[SI]
    CALL PRINT_NUM
    WZ_NEWLINE

VIEW_SKIP:
    ADD  SI, 2
    ADD  DI, 20
    ADD  BX, 10
    LOOP VIEW_LOOP

    WZ_NEWLINE
    RET
VIEW_PRODUCTS ENDP

ADD_PRODUCT PROC
    WZ_NEWLINE

    MOV  CX, MAX_PRODUCTS
    MOV  SI, 0

FIND_EMPTY_SLOT:
    MOV  AX, ProdIDs[SI]
    CMP  AX, 0
    JE   SLOT_FOUND
    ADD  SI, 2
    LOOP FIND_EMPTY_SLOT

    DISPLAY_STR MSG_PROD_FULL
    RET

SLOT_FOUND:
    
    MOV  AX, SI
    MOV  BL, 2
    DIV  BL
    XOR  AH, AH
    MOV  BL, 20
    MUL  BL 
    MOV  DI, AX

    MOV  AX, SI
    MOV  BL, 2
    DIV  BL
    XOR  AH, AH
    MOV  BL, 10
    MUL  BL 
    MOV  BP, AX
    PUSH SI
    PUSH DI
    PUSH BP

   
    DISPLAY_STR PROMPT_ID
    CALL READ_NUM
    MOV  TEMP_ID, AX

  
    MOV  CX, MAX_PRODUCTS
    MOV  DI, 0

CHECK_DUP_LOOP:
    MOV  BX, ProdIDs[DI]
    CMP  BX, 0
    JE   DUP_NEXT

    CMP  BX, TEMP_ID
    JE   DUP_FOUND

DUP_NEXT:
    ADD  DI, 2
    LOOP CHECK_DUP_LOOP

    JMP  COLLECT_FIELDS

DUP_FOUND:
    POP  BP
    POP  DI
    POP  SI
    WZ_NEWLINE
    DISPLAY_STR MSG_PROD_EXISTS
    RET

COLLECT_FIELDS:
    WZ_NEWLINE
    DISPLAY_STR PROMPT_NAME
    LEA  DX, NAME_BUFFER
    MOV  AH, 0AH
    INT  21H

    WZ_NEWLINE
    DISPLAY_STR PROMPT_CAT
    LEA  DX, CAT_BUFFER
    MOV  AH, 0AH
    INT  21H

    WZ_NEWLINE
    DISPLAY_STR PROMPT_PRICE
    CALL READ_NUM
    MOV  TEMP_PRICE, AX

    WZ_NEWLINE
    DISPLAY_STR PROMPT_QTY
    CALL READ_NUM
    MOV  TEMP_QTY, AX

    WZ_NEWLINE
    DISPLAY_STR PROMPT_SID
    CALL READ_NUM
    MOV  TEMP_SID, AX

    POP  BP
    POP  DI
    POP  SI

    MOV  AX, TEMP_ID
    MOV  ProdIDs[SI], AX

    MOV  AX, TEMP_PRICE
    MOV  ProdPrices[SI], AX

    MOV  AX, TEMP_QTY
    MOV  ProdQtys[SI], AX

    MOV  AX, TEMP_SID
    MOV  ProdSIDPtrs[SI], AX

 
    MOV  CL, [NAME_BUFFER + 1]
    XOR  CH, CH
    MOV  BX, DI
    LEA  DI, ProdNames
    ADD  DI, BX

    LEA  SI, NAME_BUFFER + 2
COPY_NAME_LOOP:
    MOV  AL, [SI]
    MOV  [DI], AL
    INC  SI
    INC  DI
    LOOP COPY_NAME_LOOP
    MOV  BYTE PTR [DI], '$'
    MOV  CL, [CAT_BUFFER + 1]
    XOR  CH, CH
    MOV  BX, BP
    LEA  DI, ProdCats
    ADD  DI, BX
    LEA  SI, CAT_BUFFER + 2

COPY_CAT_LOOP:
    MOV  AL, [SI]
    MOV  [DI], AL
    INC  SI
    INC  DI
    LOOP COPY_CAT_LOOP
    MOV  BYTE PTR [DI], '$'

    WZ_NEWLINE
    DISPLAY_STR MSG_PROD_ADDED
    RET
ADD_PRODUCT ENDP

SEARCH_ITEM PROC
    WZ_NEWLINE
    DISPLAY_STR MSG_SEARCH_PMPT

    MOV  AH, 01H
    INT  21H
    MOV  BL, AL

    MOV  AH, 01H
    INT  21H

    CMP  BL, '1'
    JE   SEARCH_BY_ID
    CMP  BL, '2'
    JE   SEARCH_BY_NAME

    DISPLAY_STR MSG_INVALID
    RET

SEARCH_BY_ID:
    WZ_NEWLINE
    DISPLAY_STR PROMPT_ID
    CALL READ_NUM
    MOV  SEARCH_ID, AX

    MOV  CX, MAX_PRODUCTS
    MOV  SI, 0

FIND_ID_LOOP:
    MOV  AX, ProdIDs[SI]
    CMP  AX, SEARCH_ID
    JE   ITEM_FOUND
    ADD  SI, 2
    LOOP FIND_ID_LOOP

    WZ_NEWLINE
    DISPLAY_STR MSG_NOT_FOUND
    RET

SEARCH_BY_NAME:
    WZ_NEWLINE
    DISPLAY_STR PROMPT_NAME
    LEA  DX, NAME_BUFFER
    MOV  AH, 0AH
    INT  21H

    MOV  BP, 0              
    MOV  SI, 0 

NAME_OUTER_LOOP:
    CMP  BP, MAX_PRODUCTS
    JGE  NAME_NOT_FOUND

    MOV  AX, ProdIDs[SI]
    CMP  AX, 0
    JE   NAME_SKIP
    PUSH SI
    PUSH BP

    MOV  AX, BP
    MOV  BL, 20
    MUL  BL 
    MOV  DI, AX 
   
    MOV  CL, [NAME_BUFFER + 1] 
    XOR  CH, CH
    MOV  BX, 0                   
NAME_CMP_LOOP:
    CMP  BX, CX
    JGE  NAME_CMP_ALL_MATCHED    

    LEA  SI, NAME_BUFFER + 2
    ADD  SI, BX
    MOV  AL, [SI]                

    LEA  SI, ProdNames
    ADD  SI, DI
    ADD  SI, BX
    MOV  AH, [SI]                

    CMP  AL, AH                  
    JNE  NAME_CMP_NOMATCH

    INC  BX
    JMP  NAME_CMP_LOOP

NAME_CMP_ALL_MATCHED:
    
    LEA  SI, ProdNames
    ADD  SI, DI
    ADD  SI, CX                  
    MOV  AL, [SI]                

    POP  BP
    POP  SI                      

    CMP  AL, '$'
    JE   ITEM_FOUND              
    JMP  NAME_SKIP

NAME_CMP_NOMATCH:
    POP  BP
    POP  SI                      

NAME_SKIP:
    INC  BP
    ADD  SI, 2
    JMP  NAME_OUTER_LOOP

NAME_NOT_FOUND:
    WZ_NEWLINE
    DISPLAY_STR MSG_NOT_FOUND
    RET


ITEM_FOUND:
    WZ_NEWLINE
    DISPLAY_STR MSG_PROD_HDR
    WZ_NEWLINE
    DISPLAY_STR MSG_SEPARATOR
    WZ_NEWLINE

    
    MOV  AX, SI
    MOV  BL, 2
    DIV  BL
    XOR  AH, AH
    MOV  BL, 20
    MUL  BL
    MOV  DI, AX             

    MOV  AX, SI
    MOV  BL, 2
    DIV  BL
    XOR  AH, AH
    MOV  BL, 10
    MUL  BL
    MOV  BX, AX             

    MOV  AX, ProdIDs[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    LEA  DX, ProdNames[DI]
    MOV  AH, 09H
    INT  21H
    DISPLAY_STR SPACE2

    LEA  DX, ProdCats[BX]
    MOV  AH, 09H
    INT  21H
    DISPLAY_STR SPACE2

    MOV  AX, ProdPrices[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    MOV  AX, ProdQtys[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    MOV  AX, ProdSIDPtrs[SI]
    CALL PRINT_NUM
    WZ_NEWLINE
    RET
SEARCH_ITEM ENDP

READ_NUM PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV  BX, 0             
    MOV  CX, 10             

WAIT_FIRST_DIGIT:
    MOV  AH, 01H
    INT  21H

    CMP  AL, 0DH          
    JE   READ_EARLY_EXIT

    CMP  AL, '0'
    JL   WAIT_FIRST_DIGIT
    CMP  AL, '9'
    JG   WAIT_FIRST_DIGIT

    SUB  AL, 30H            
    XOR  AH, AH
    MOV  BX, AX

READ_MORE_DIGITS:
    MOV  AH, 01H
    INT  21H

    CMP  AL, 0DH
    JE   READ_DONE

    CMP  AL, '0'
    JL   READ_DONE
    CMP  AL, '9'
    JG   READ_DONE

    SUB  AL, 30H
    XOR  AH, AH
    MOV  SI, AX             

    MOV  AX, BX
    MUL  CX                 
    ADD  AX, SI             
    MOV  BX, AX

    JMP  READ_MORE_DIGITS

READ_EARLY_EXIT:
    MOV  BX, 0

READ_DONE:
    MOV  AX, BX
    POP  DX
    POP  CX
    POP  BX
    RET
READ_NUM ENDP

PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP  AX, 0
    JNE  PNUM_NOT_ZERO
    PRINT_CHAR '0'
    JMP  PNUM_END

PNUM_NOT_ZERO:
    MOV  BX, 10
    MOV  CX, 0            

PNUM_CALC_DIGITS:
    MOV  DX, 0
    DIV  BX                 
    PUSH DX                 
    INC  CX
    CMP  AX, 0
    JNE  PNUM_CALC_DIGITS

PNUM_PRINT_DIGITS:
    POP  DX                 
    ADD  DL, 30H            
    MOV  AH, 02H
    INT  21H
    LOOP PNUM_PRINT_DIGITS  

PNUM_END:
    POP  DX
    POP  CX
    POP  BX
    POP  AX
    RET
PRINT_NUM ENDP

RESTOCK_PRODUCT PROC
    WZ_NEWLINE
    DISPLAY_STR PROMPT_ID
    CALL READ_NUM
    MOV  SEARCH_ID, AX

    MOV  CX, MAX_PRODUCTS
    MOV  SI, 0

FIND_RESTOCK_SLOT:
    MOV  AX, ProdIDs[SI]
    CMP  AX, SEARCH_ID
    JE   RESTOCK_FOUND
    ADD  SI, 2
    LOOP FIND_RESTOCK_SLOT

    WZ_NEWLINE
    DISPLAY_STR MSG_NOT_FOUND
    RET

RESTOCK_FOUND:
    WZ_NEWLINE
    DISPLAY_STR PROMPT_QTY
    CALL READ_NUM
    MOV  BX, AX

    MOV  AX, ProdQtys[SI]
    ADD  AX, BX             
    JO   RESTOCK_OVERFLOW   

    MOV  ProdQtys[SI], AX
    WZ_NEWLINE
    DISPLAY_STR MSG_RESTOCKED
    RET

RESTOCK_OVERFLOW:
    WZ_NEWLINE
    DISPLAY_STR MSG_OVERFLOW
    RET
RESTOCK_PRODUCT ENDP

SELL_PRODUCT PROC
    WZ_NEWLINE
    DISPLAY_STR PROMPT_ID
    CALL READ_NUM
    MOV  SEARCH_ID, AX

    MOV  CX, MAX_PRODUCTS
    MOV  SI, 0

FIND_SELL_SLOT:
    MOV  AX, ProdIDs[SI]
    CMP  AX, SEARCH_ID
    JE   SELL_FOUND
    ADD  SI, 2
    LOOP FIND_SELL_SLOT

    WZ_NEWLINE
    DISPLAY_STR MSG_NOT_FOUND
    RET

SELL_FOUND:
    MOV  AX, ProdQtys[SI]
    CMP  AX, 0              
    JLE  SELL_NO_STOCK

    WZ_NEWLINE
    DISPLAY_STR PROMPT_QTY
    CALL READ_NUM
    MOV  BX, AX

    MOV  AX, ProdQtys[SI]
    CMP  AX, BX             
    JL   SELL_NO_STOCK

    SUB  ProdQtys[SI], BX   
    WZ_NEWLINE
    DISPLAY_STR MSG_SOLD
    RET

SELL_NO_STOCK:
    WZ_NEWLINE
    DISPLAY_STR MSG_NO_STOCK
    RET
SELL_PRODUCT ENDP

CALC_TOTAL_VALUE PROC
    MOV  TOTAL_VAL_LOW,  0
    MOV  TOTAL_VAL_HIGH, 0

    MOV  CX, MAX_PRODUCTS
    MOV  SI, 0

CALC_LOOP:
    MOV  AX, ProdIDs[SI]
    CMP  AX, 0
    JE   CALC_SKIP

    MOV  AX, ProdPrices[SI]
    MOV  BX, ProdQtys[SI]
    MUL  BX                

    ADD  TOTAL_VAL_LOW,  AX
    ADC  TOTAL_VAL_HIGH, DX 

CALC_SKIP:
    ADD  SI, 2
    LOOP CALC_LOOP

    WZ_NEWLINE
    DISPLAY_STR MSG_TOTAL_LBL

    CMP  TOTAL_VAL_HIGH, 0
    JNE  PRINT_32BIT_TOTAL

    MOV  AX, TOTAL_VAL_LOW
    CALL PRINT_NUM
    WZ_NEWLINE
    RET

PRINT_32BIT_TOTAL:
    MOV  AX, TOTAL_VAL_HIGH
    CALL PRINT_NUM
    PRINT_CHAR ','
    MOV  AX, TOTAL_VAL_LOW
    CALL PRINT_NUM
    WZ_NEWLINE
    RET
CALC_TOTAL_VALUE ENDP

LOW_STOCK_ALERT PROC
    WZ_NEWLINE
    DISPLAY_STR MSG_LOW_HDR
    WZ_NEWLINE
    DISPLAY_STR MSG_PROD_HDR
    WZ_NEWLINE
    DISPLAY_STR MSG_SEPARATOR
    WZ_NEWLINE

    MOV  CX, MAX_PRODUCTS
    MOV  SI, 0              
    MOV  DX, 0              

LOW_LOOP:
    MOV  AX, ProdIDs[SI]
    CMP  AX, 0
    JE   LOW_SKIP

    MOV  AX, ProdQtys[SI]
    CMP  AX, 5              
    JGE  LOW_SKIP

    PUSH DX
    PUSH SI
    MOV  AX, DX
    MOV  BL, 20
    MUL  BL
    MOV  DI, AX
    POP  SI
    POP  DX

    PUSH DX
    PUSH SI
    MOV  AX, DX
    MOV  BL, 10
    MUL  BL
    MOV  BX, AX
    POP  SI
    POP  DX

    MOV  AX, ProdIDs[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    LEA  AX, ProdNames
    ADD  AX, DI
    MOV  DX, AX
    MOV  AH, 09H
    INT  21H
    DISPLAY_STR SPACE2

    LEA  AX, ProdCats
    ADD  AX, BX
    MOV  DX, AX
    MOV  AH, 09H
    INT  21H
    DISPLAY_STR SPACE2

    MOV  AX, ProdPrices[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    MOV  AX, ProdQtys[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    MOV  AX, ProdSIDPtrs[SI]
    CALL PRINT_NUM
    WZ_NEWLINE

LOW_SKIP:
    ADD  SI, 2
    INC  DX
    LOOP LOW_LOOP

    WZ_NEWLINE
    RET
LOW_STOCK_ALERT ENDP

MANAGE_SUPPLIERS PROC
SUPP_MGR_LOOP:
    CLEAR_SCREEN
    WZ_NEWLINE
    DISPLAY_STR MSG_SUPP_MNGR
    WZ_NEWLINE
    DISPLAY_STR MSG_SUPP_MA
    WZ_NEWLINE
    DISPLAY_STR MSG_SUPP_MB
    WZ_NEWLINE
    DISPLAY_STR MSG_SUPP_MC
    WZ_NEWLINE
    DISPLAY_STR MSG_CHOICE

    MOV  AH, 01H
    INT  21H
    MOV  BL, AL

    MOV  AH, 01H
    INT  21H

    CMP  BL, '1'
    JE   DO_VIEW_SUPPS
    CMP  BL, '2'
    JE   DO_ADD_SUPP
    CMP  BL, '0'
    JE   SUPP_MGR_BACK

    WZ_NEWLINE
    DISPLAY_STR MSG_INVALID
    JMP  SUPP_MGR_LOOP

DO_VIEW_SUPPS:
    CALL VIEW_SUPPLIERS
    JMP  SUPP_MGR_LOOP

DO_ADD_SUPP:
    CALL ADD_SUPPLIER
    JMP  SUPP_MGR_LOOP

SUPP_MGR_BACK:
    RET
MANAGE_SUPPLIERS ENDP

VIEW_SUPPLIERS PROC
    WZ_NEWLINE
    DISPLAY_STR MSG_SUPP_HDR
    WZ_NEWLINE
    DISPLAY_STR MSG_SEPARATOR
    WZ_NEWLINE

    MOV  CX, MAX_SUPPLIERS
    MOV  SI, 0              
    MOV  DI, 0              
    MOV  BX, 0              

VIEW_SUPP_LOOP:
    MOV  AX, SuppIDs[SI]
    CMP  AX, 0
    JE   VIEW_SUPP_SKIP

    MOV  AX, SuppIDs[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    LEA  DX, SuppContacts[DI]
    MOV  AH, 09H
    INT  21H
    DISPLAY_STR SPACE2

    MOV  AL, SuppStatus[BX]
    CMP  AL, 01H
    JE   PRINT_ACTIVE

    DISPLAY_STR MSG_INACTIVE
    JMP  VIEW_SUPP_NL

PRINT_ACTIVE:
    DISPLAY_STR MSG_ACTIVE

VIEW_SUPP_NL:
    WZ_NEWLINE

VIEW_SUPP_SKIP:
    ADD  SI, 2
    ADD  DI, 12
    INC  BX
    LOOP VIEW_SUPP_LOOP

    WZ_NEWLINE
    RET
VIEW_SUPPLIERS ENDP

ADD_SUPPLIER PROC
    WZ_NEWLINE

    MOV  CX, MAX_SUPPLIERS
    MOV  SI, 0

FIND_SUPP_SLOT:
    MOV  AX, SuppIDs[SI]
    CMP  AX, 0
    JE   SUPP_SLOT_FOUND
    ADD  SI, 2
    LOOP FIND_SUPP_SLOT

    DISPLAY_STR MSG_SUPP_FULL
    RET

SUPP_SLOT_FOUND:
    MOV  AX, SI
    MOV  BL, 2
    DIV  BL                 
    XOR  AH, AH

    MOV  BX, AX             

    MOV  CL, 12
    MUL  CL                 
    MOV  DI, AX             

    
    PUSH SI
    PUSH DI
    PUSH BX

    
    DISPLAY_STR PROMPT_SID
    CALL READ_NUM
    MOV  TEMP_SID, AX

   
    WZ_NEWLINE
    DISPLAY_STR PROMPT_CONT
    LEA  DX, CONT_BUFFER
    MOV  AH, 0AH
    INT  21H

    
    WZ_NEWLINE
    DISPLAY_STR SPACE2
    PRINT_CHAR 'A'
    PRINT_CHAR 'c'
    PRINT_CHAR 't'
    PRINT_CHAR 'i'
    PRINT_CHAR 'v'
    PRINT_CHAR 'e'
    PRINT_CHAR '?'
    PRINT_CHAR ' '
    PRINT_CHAR '1'
    PRINT_CHAR '/'
    PRINT_CHAR '0'
    PRINT_CHAR ':'
    PRINT_CHAR ' '

    MOV  AH, 01H
    INT  21H
    MOV  DL, AL             
    MOV  AH, 01H
    INT  21H

    
    POP  BX
    POP  DI
    POP  SI

    
    MOV  AX, TEMP_SID
    MOV  SuppIDs[SI], AX

    MOV  CL, [CONT_BUFFER + 1]
    XOR  CH, CH

    MOV  AX, DI                     
    LEA  DI, SuppContacts
    ADD  DI, AX                     
    LEA  SI, CONT_BUFFER + 2

COPY_CONT_LOOP:
    MOV  AL, [SI]
    MOV  [DI], AL
    INC  SI
    INC  DI
    LOOP COPY_CONT_LOOP     
    MOV  BYTE PTR [DI], '$'

    
    CMP  DL, '1'
    JE   SET_ACTIVE_STATUS

    MOV  SuppStatus[BX], 00H
    JMP  SUPP_STATUS_DONE

SET_ACTIVE_STATUS:
    MOV  SuppStatus[BX], 01H

SUPP_STATUS_DONE:
    WZ_NEWLINE
    DISPLAY_STR MSG_SUPP_ADDED
    RET
ADD_SUPPLIER ENDP

SUPPLIER_MENU PROC
SUPP_MENU_LOOP:
    CLEAR_SCREEN
    WZ_NEWLINE
    DISPLAY_STR MSG_BORDER
    WZ_NEWLINE
    DISPLAY_STR MSG_SUPP_TITLE
    WZ_NEWLINE
    DISPLAY_STR MSG_BORDER
    WZ_NEWLINE
    DISPLAY_STR MSG_SUPP_1
    WZ_NEWLINE
    DISPLAY_STR MSG_SUPP_2
    WZ_NEWLINE
    DISPLAY_STR MSG_SUPP_0
    WZ_NEWLINE
    DISPLAY_STR MSG_CHOICE

    MOV  AH, 01H
    INT  21H
    MOV  BL, AL

    MOV  AH, 01H
    INT  21H

    CMP  BL, '1'
    JE   SUPP_DO_VIEW
    CMP  BL, '2'
    JE   SUPP_DO_RESTOCK
    CMP  BL, '0'
    JE   SUPP_DO_LOGOUT

    WZ_NEWLINE
    DISPLAY_STR MSG_INVALID
    JMP  SUPP_MENU_LOOP

SUPP_DO_VIEW:
    CALL VIEW_MY_PRODUCTS
    JMP  SUPP_MENU_LOOP

SUPP_DO_RESTOCK:
    CALL RESTOCK_MY_PROD
    JMP  SUPP_MENU_LOOP

SUPP_DO_LOGOUT:
    MOV  CURRENT_SID, 0
    RET
SUPPLIER_MENU ENDP

VIEW_MY_PRODUCTS PROC
    WZ_NEWLINE
    DISPLAY_STR MSG_PROD_HDR
    WZ_NEWLINE
    DISPLAY_STR MSG_SEPARATOR
    WZ_NEWLINE

    MOV  CX, MAX_PRODUCTS
    MOV  SI, 0
    MOV  DX, 0              

VIEW_MY_LOOP:
    MOV  AX, ProdIDs[SI]
    CMP  AX, 0
    JE   VIEW_MY_SKIP

    MOV  AX, ProdSIDPtrs[SI]
    CMP  AX, CURRENT_SID    
    JNE  VIEW_MY_SKIP

    
    PUSH SI
    PUSH DX
    MOV  AX, DX
    MOV  BL, 20
    MUL  BL
    MOV  DI, AX
    POP  DX
    POP  SI

    
    PUSH SI
    PUSH DX
    MOV  AX, DX
    MOV  BL, 10
    MUL  BL
    MOV  BX, AX
    POP  DX
    POP  SI

    MOV  AX, ProdIDs[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    LEA  AX, ProdNames
    ADD  AX, DI
    MOV  DX, AX
    MOV  AH, 09H
    INT  21H
    DISPLAY_STR SPACE2

    LEA  AX, ProdCats
    ADD  AX, BX
    MOV  DX, AX
    MOV  AH, 09H
    INT  21H
    DISPLAY_STR SPACE2

    MOV  AX, ProdPrices[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    MOV  AX, ProdQtys[SI]
    CALL PRINT_NUM
    DISPLAY_STR SPACE3

    MOV  AX, ProdSIDPtrs[SI]
    CALL PRINT_NUM
    WZ_NEWLINE

VIEW_MY_SKIP:
    ADD  SI, 2
    INC  DX
    LOOP VIEW_MY_LOOP

    WZ_NEWLINE
    RET
VIEW_MY_PRODUCTS ENDP


RESTOCK_MY_PROD PROC
    WZ_NEWLINE
    DISPLAY_STR PROMPT_ID
    CALL READ_NUM
    MOV  SEARCH_ID, AX

    MOV  CX, MAX_PRODUCTS
    MOV  SI, 0

FIND_MY_SLOT:
    MOV  AX, ProdIDs[SI]
    CMP  AX, SEARCH_ID
    JE   CHECK_SID_OWNERSHIP
    ADD  SI, 2
    LOOP FIND_MY_SLOT

    WZ_NEWLINE
    DISPLAY_STR MSG_NOT_FOUND
    RET

CHECK_SID_OWNERSHIP:
    MOV  AX, ProdSIDPtrs[SI]
    CMP  AX, CURRENT_SID    
    JNE  MY_RESTOCK_DENIED

    WZ_NEWLINE
    DISPLAY_STR PROMPT_QTY
    CALL READ_NUM
    MOV  BX, AX

    MOV  AX, ProdQtys[SI]
    ADD  AX, BX
    JO   MY_RESTOCK_OVERFLOW

    MOV  ProdQtys[SI], AX
    WZ_NEWLINE
    DISPLAY_STR MSG_RESTOCKED
    RET

MY_RESTOCK_DENIED:
    WZ_NEWLINE
    DISPLAY_STR MSG_NOT_FOUND
    RET

MY_RESTOCK_OVERFLOW:
    WZ_NEWLINE
    DISPLAY_STR MSG_OVERFLOW
    RET
RESTOCK_MY_PROD ENDP

USER_MENU PROC
USER_MENU_LOOP:
    CLEAR_SCREEN
    WZ_NEWLINE
    DISPLAY_STR MSG_BORDER
    WZ_NEWLINE
    DISPLAY_STR MSG_USER_TITLE
    WZ_NEWLINE
    DISPLAY_STR MSG_BORDER
    WZ_NEWLINE
    DISPLAY_STR MSG_USER_1
    WZ_NEWLINE
    DISPLAY_STR MSG_USER_2
    WZ_NEWLINE
    DISPLAY_STR MSG_USER_0
    WZ_NEWLINE
    DISPLAY_STR MSG_CHOICE

    MOV  AH, 01H
    INT  21H
    MOV  BL, AL

    MOV  AH, 01H
    INT  21H

    CMP  BL, '1'
    JE   USER_DO_VIEW
    CMP  BL, '2'
    JE   USER_DO_SEARCH
    CMP  BL, '0'
    JE   USER_DO_LOGOUT

    WZ_NEWLINE
    DISPLAY_STR MSG_INVALID
    JMP  USER_MENU_LOOP

USER_DO_VIEW:
    CALL VIEW_PRODUCTS
    JMP  USER_MENU_LOOP

USER_DO_SEARCH:
    CALL SEARCH_ITEM
    JMP  USER_MENU_LOOP

USER_DO_LOGOUT:
    RET
USER_MENU ENDP

END MAIN