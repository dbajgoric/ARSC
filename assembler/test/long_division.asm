    // Performs long division dvnd/dvsr, where dvnd,dvsr > 0
    LDA DVSR
    TCA
    ADD DVND
    BIN DVND_LT_DVSR
    BIP DVND_GT_DVSR
    // DVND == DVSR
    LDA ONE
    STA QUOTIENT
    LDA ZERO
    STA REMAINDER
    BRU DIV_END

DVND_LT_DVSR:
    // DVND < DVSR
    LDA ZERO
    STA QUOTIENT
    LDA DVND
    STA REMAINDER
    BRU DIV_END

DVND_GT_DVSR:
    // DVND > DVSR
    LDA DVSR
    STA TMP_Y
    LDX ZERO,1
    LDA ZERO
    STA BUFFER

PREP_BUFF:
    LDA TMP_Y
    BIP PREP_BUFF_CHCK_COND
    BRU PREP_BUFF_END

PREP_BUFF_CHCK_COND:
    // Check if TMP_Y <= DVND
    TCA
    ADD DVND
    BIN PREP_BUFF_END
    // Index += 1
    STX IDX,1
    LDA IDX
    ADD ONE
    STA IDX
    LDX IDX,1
    // BUFFER[INDEX] = TMP_Y
    LDA TMP_Y
    STA BUFFER,1
    // TMP_Y = 2*TMP_Y
    SHL
    STA TMP_Y
    BRU PREP_BUFF

PREP_BUFF_END:

    // TMP_Y = BUFFER[INDEX]
    LDA BUFFER,1
    STA TMP_Y
    // TMP_X = DVND
    LDA DVND
    STA TMP_X
    // Index -= 1
    STX IDX,1
    LDA IDX
    ADD MINONE
    STA IDX
    LDX IDX,1
    // Quotient = 0
    LDA ZERO
    STA QUOTIENT

DIV_LOOP:
    // Index >= 0
    STX IDX,1
    LDA IDX
    BIN SET_REMAINDER
    LDA TMP_Y
    TCA
    ADD TMP_X
    BIN TMPX_LT_TMPY
    // Quotient = 2*Quotient + 1
    LDA QUOTIENT
    SHL
    ADD ONE
    STA QUOTIENT
    // TMP_X -= TMP_Y
    LDA TMP_Y
    TCA
    ADD TMP_X
    STA TMP_X
    BRU DIV_LOOP_NEXT

TMPX_LT_TMPY:
    // Quotient = 2*Quotient
    LDA QUOTIENT
    SHL
    STA QUOTIENT

DIV_LOOP_NEXT:
    // TMP_Y -= BUFFER[INDEX]
    LDA BUFFER,1
    TCA
    ADD TMP_Y
    STA TMP_Y
    // Index -= 1
    STX IDX,1
    LDA IDX
    ADD MINONE
    STA IDX
    LDX IDX,1
    BRU DIV_LOOP

SET_REMAINDER:
    LDA TMP_X
    STA REMAINDER

DIV_END:
    HLT

DVND BSS 1
DVSR BSS 1
QUOTIENT BSS 1
REMAINDER BSS 1
BUFFER BSS 16
TMP_X BSS 1
TMP_Y BSS 1
IDX BSS 1
ZERO BSC 0
ONE BSC 1
MINONE BSC -1

END