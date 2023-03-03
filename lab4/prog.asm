;include macro.inc
assume cs: code, ds: data

data segment
    newline db 0Ah, "$" ; we use this to print newline
    string db 100, 99 dup ('$')
    string1 db 100, 99 dup ('$')
    max_len dw 16
    num_a db 100, 99 dup (0) ; first num
    num_b db 100, 99 dup (0) ; second num
    num_c db 100, 99 dup (0) ; result
    notation db 10 ; decimal or hex
    cmpres db 0

    ; error messages
    error_wrong_symbol db 100, " error: non-numerical symbol $"
data ends

code segment

initds macro
    mov ax, data
    mov ds, ax
endm

endprogram macro
    mov ah, 4ch
    int 21h
endm

; print string
print macro str
    push ax
    mov ah, 09h
    lea dx, str
    add dx, 2 ; first 2 chars stand for length
    int 21h
    pop ax
endm

; print string
println macro str
    print str
    ; print newline
    push ax
    mov ah, 09h
    lea dx, newline
    int 21h
    pop ax
endm

printchar macro char
    push ax
    push dx
    mov ah, 2
    mov dl, char
    int 21h
    pop dx
    pop ax
endm

printdigit macro digit
    push dx
    mov dh, digit
    add dh, '0'
    printchar dh
    sub dh, '0'
    pop dx
endm

; throw error
error macro message
    println message
    endprogram
endm

error_symbol macro message, symbol
    print message
    printchar symbol
    endprogram
endm

; scan str
scanstr macro string
    mov dx, offset string
    ; considering that sting lies in dx
    ; input string
    xor ax, ax
    mov ah, 0Ah
    int 21h
    
    ; fix string adding '$' to it's end
    mov si, dx
    xor bh, bh
    mov bl, [si+1]
    mov ch, '$'
    add bx, 2
    mov [si+bx], ch

    ; print newline
    mov dx, offset newline
    mov ah, 09h
    int 21h
endm

tostring macro num, output_string
    push ax
    push bx
    push cx
    push di
    mov ax, num
	mov di, 4 ; Elem diffex
	mov cx, 5 ; Iterations
	MOV BL,10
	mov output_string[5], 10
	mov output_string[6], 13
	goto:
		DIV BL ; Get another digit
		mov output_string[di], ah
		add output_string[di],"0"
		mov ah,0
		sub di,1 ;di=di-1
	loop goto
	
    pop di
    pop cx
    pop bx
    pop ax
endm

ifless macro a, b, endmark
    cmp a, b
    jge endmark
endm

ifequal macro a, b, endmark
    cmp a, b
    je endmark
endm

ifnotspace macro symbol, endmark
    push ax
    push bx
    mov ah, ' '
    mov bh, symbol
    cmp bh, ah
    pop bx
    pop ax
    je endmark
endm

ifnotend macro symbol, endmark
    push ax
    push bx
    mov ah, '$'
    mov bh, symbol
    cmp bh, ah
    pop bx
    pop ax
    je endmark
endm

ifflag macro flagname, endmark
    push ax
    push bx
    xor ax, ax
    mov bx, flagname
    cmp bx, ax
    pop bx
    pop ax
    je endmark
endm

ifnotnumber macro symbol, endmark
    push ax
    mov al, '/'
    mov ah, '0'
    add ah, notation
    ifless symbol, ah, _&endmark
    ifless al, symbol, _&endmark
        pop ax
        jmp endmark
    _&endmark&:   
    pop ax
endm

ifnotminus macro symbol, endmark
    push ax
    push bx
    mov ah, '-'
    mov bh, symbol
    cmp bh, ah
    pop bx
    pop ax
    je endmark
endm

ifminus macro symbol, endmark
    push ax
    push bx
    mov ah, '-'
    mov bh, symbol
    cmp bh, ah
    pop bx
    pop ax
    jne endmark
endm

settrue macro flagname
    mov flagname, 1
endm

setfalse macro flagname
    mov flagname, 0
endm

movesymbol macro s1, s2
    push ax
    mov ah, s2
    mov s1, ah
    pop ax
endm

strlen macro str, reg
    xor reg&x, reg&x
    mov reg&l, str[1]
endm

; hex digit mapping
; working with ch register
tohex proc
    mov cl, 60h
    ifless cl, ch, tohexendif
        sub ch, 'a'
        add ch, ':'
    tohexendif:
    ret
tohex endp

fromhex proc
    mov cl, '9'
    ifless cl, ch, fromhexendif
        sub ch, ':'
        add ch, 'a'
    fromhexendif:
    ret
fromhex endp

numtostring proc
    mov bp, sp
    mov si, [bp + 2] ; num offset in di
    mov ax, max_len
    xor di, di ; di for indexing
    ; print sign
    add si, max_len
    mov bl, [si]
    cmp bx, 0
    je plus
        printchar '-'
        jmp endsign
    plus:
        printchar '+'
    endsign:
    sub si, max_len

    mov bx, 2
    loop_numtostring:
        mov ch, [si]
        add ch, '0'
        ; hex mapping
        call fromhex
        mov string[bx], ch

        inc si
        inc di
        inc bx
        ifless di, ax, break_numtostring
            jmp loop_numtostring
        break_numtostring:
    ret
numtostring endp

printnum macro num
    mov dx, offset num
    push dx
    call numtostring
    println string
endm

tonum proc
    mov bp, sp
    mov di, [bp + 2] ; num offset in di
    strlen string, a ; strlen in ax
    mov bx, max_len
    sub bx, ax  ; num_offset in bx
    add ax, 2
    mov si, 2 ; si for indexing
    xor dx, dx
    mov [di], dx ; fixing first digit
    loop_tonum:
        mov ch, string[si]
        ; hex mapping
        call tohex
        ; checking for number or -
        ifnotnumber ch, ok_it_is_number
        ifnotminus ch, minus_case
            error_symbol error_wrong_symbol, ch
        ok_it_is_number:


        jmp number_case
        minus_case:
            push ax
            add di, max_len
            mov ax, [di]
            not ax
            mov [di], ax
            sub di, max_len
            pop ax
            jmp endcase
        number_case:
            sub ch, '0'
            mov [di + bx], ch
        endcase:

        inc si
        inc bx
        ifless si, ax, break_tonum
            jmp loop_tonum
        break_tonum:
    ret
tonum endp

invert_sign macro num
    push di
    push ax
    mov di, max_len
    mov al, num[di]
    not al
    mov num[di], al
    pop ax
    pop di
endm

swap_nums proc
    push si
    push ax
    push bx
    mov si, max_len ;; si for indexing
    dec si
    loop_swap:
        mov al, num_a[si]
        mov bl, num_b[si]
        mov num_a[si], bl
        mov num_b[si], al

        dec si
        cmp si, 0
        je break_swap
        jmp loop_swap
    break_swap:    
    pop bx
    pop ax
    pop si
    ret
swap_nums endp

compare_nums proc
    push di
    push ax
    push bx    
    xor ax, ax
    xor bx, bx
    xor si, si

    ; checking sign
    mov di, max_len
    mov al, num_a[di]
    mov bl, num_b[di]

    cmp ax, bx
    je loop_comp
    jl sign_less
        mov cmpres, 2        
        jmp endcompare_nums
    sign_less:
        mov cmpres, 1
        jmp endcompare_nums
    
    loop_comp:
        mov al, num_a[si]
        mov bl, num_b[si]
        cmp ax, bx
        je cmp_equal
        jl equal_less
            mov cmpres, 1
            jmp break_comp
        equal_less:
            mov cmpres, 2
            jmp break_comp
        cmp_equal:

        inc si
        cmp si, max_len
        jge break_comp
        jmp loop_comp
    break_comp:

    ; ; if signs - -
    ; mov di, max_len
    ; mov al, num_a[di]
    ; cmp al, 0
    ; jne endifcomp0
    ;     xor ax, ax
    ;     mov al, cmpres
    ;     xor al, 11b ; 10 xor 11 = 01; 01 xor 11 = 10
    ;     mov cmpres, al
    ; endifcomp0:

    endcompare_nums:
    pop bx
    pop ax
    pop di
    ret
compare_nums endp

scannum macro num
    scanstr string
    mov dx, offset num
    push dx
    call tonum
endm

calculate_sum proc
    ; signes comp
    mov di, max_len
    mov al, num_a[di]
    mov bl, num_b[di]
    cmp al, bl
    je skipdiff
        invert_sign num_b
        call calculate_diff
        ret
    skipdiff:

    ; sign
    call compare_nums
    cmp cmpres, 2
    jne not_swap_
        call swap_nums
        invert_sign num_c
    not_swap_:

    mov di, max_len
    mov al, num_a[di]
    cmp al, 0
    je invert_sign_in_diff_
        invert_sign num_c
    invert_sign_in_diff_:

    mov si, max_len
    sub si, 1
    loop_sum:
        ; put local sum in ch
        xor cx, cx
        mov ah, num_a[si]
        mov bh, num_b[si]
        mov ch, num_c[si]

        add ch, ah
        add ch, bh
        
        ; if overflow
        mov cl, notation
        dec cl
        ifless cl, ch, sum_overflow
            ; reminder in ch
            sub ch, notation
            ; add 1 to next digit
            mov cl, 1
            mov num_c[si - 1], cl
        sum_overflow:

        mov num_c[si], ch

        dec si
        cmp si, 0
        jl break_sum
        jmp loop_sum
    break_sum:
    ret
calculate_sum endp

calculate_diff proc
    ; signes comp
    mov di, max_len
    mov al, num_a[di]
    mov bl, num_b[di]
    cmp al, bl
    je skipsum
        invert_sign num_b
        call calculate_sum
        ret
    skipsum:

    ; sign
    call compare_nums
    cmp cmpres, 2
    jne not_swap
        call swap_nums
        invert_sign num_c
    not_swap:

    mov di, max_len
    mov al, num_a[di]
    cmp al, 0
    je invert_sign_in_diff
        invert_sign num_c
    invert_sign_in_diff:

    mov si, max_len
    sub si, 1
    xor dh, dh 

    loop_diff:
        ; put local diff in ch
        xor cx, cx
        mov ah, num_a[si]
        mov bh, num_b[si]

        add ch, ah
        sub ch, bh
        sub ch, dh
        
        ; if overflow
        xor cl, cl ; cl <--- 0
        xor dh, dh ; dh <--- 0
        ifless ch, cl, diff_overflow
            ; reminder in ch
            add ch, notation
            ; add 1 to next digit
            mov dh, 1
            
        diff_overflow:

        mov num_c[si], ch

        dec si
        cmp si, 0
        jl break_diff
        jmp loop_diff
    break_diff:
    ret
calculate_diff endp

calculate_prod proc
    mov di, max_len
    sub di, 1
    xor bx, bx
    
    loop_sumprod:
        mov si, max_len
        sub si, 1
        loop_prod:
           
            xor ax, ax
            xor cx, cx
            xor dx, dx
            mov al, num_a[si]
            mov dl, num_b[di]
            
            ; put local prod in al
            mul dx
            
            ; reminder in ch
            mov cl, notation
            div cl
            ; add to next digit
            sub si, bx
            add num_c[si - 1], al
            add num_c[si], ah
            add si, bx

            dec si
            cmp si, 0
            jl break_prod
            jmp loop_prod
        break_prod:

        inc bx
        dec di
        cmp di, 0
        jl break_sumprod
        jmp loop_sumprod
    break_sumprod:

    mov di, max_len
    sub di, 1
    loop_fix:
        ; reminder in ch
        xor ax, ax
        mov cl, notation
        mov al, num_c[di]
        div cl
        ; add to next digit
        add num_c[di - 1], al
        mov num_c[di], ah

        dec di
        cmp di, 0
        jl break_fix
        jmp loop_fix
    break_fix:

    ; sign calculating
    mov di, max_len
    push ax
    push bx
    mov al, num_a[di]
    mov bl, num_b[di]
    xor al, bl
    mov num_c[di], al
    pop bx
    pop ax
    ret
calculate_prod endp

start:
    initds

    scannum num_a
    scannum num_b
    xor dx, dx
    mov num_c[0], dh ; fixing first digit of num_c

    ; call calculate_sum
    ; call calculate_diff
    call calculate_prod
    ; call compare_nums
    
    ; printdigit cmpres

    printnum num_a
    printnum num_b    
    printnum num_c
    
    endprogram
code ends
end start