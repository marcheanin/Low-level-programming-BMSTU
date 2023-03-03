init macro 
    mov ax, data
	mov ds, ax
	mov es, ax
	xor ax, ax
endm

print macro strart
    push ax dx
    xor ax, ax
	mov dx, offset strart
	mov ah, 09h
	int 21h
	pop dx ax
endm

tostr macro num
    local do, do2
      push ax
    push cx
    xor cx, cx
    xor ax, ax
    mov ax, num
    xor num, num
    mov bl, 10
    do:
        inc cx
        div bl ; ah -остаток, al - целая часть
        add ah, '0'
        push ax
        xor ah, ah
        cmp ax, 0
        je lbl
    jmp do
    lbl:
        mov di, offset msg
        do2:
            pop ax
            mov [di], ah
            inc di
        loop do2
        mov ah, '$'
        mov [di], ah
        pop cx
        pop ax
endm

input macro src 
    push ax dx
	mov ah, 0ah
	lea dx, src
	int 21h
    pop dx ax
endm

if_equal macro a, b, labl
    cmp a, b 
    je labl
endm

if_not_equal macro a, b, labl
    cmp a, b 
    jne labl
endm

count_words macro text
    mov si, 3
    mov di, 3
    mov bx, 0  ;счетчик слов
    mov cx, 0  ;проверка на то, есть ли перед пробелом слово

    compare:
        ; если конец строки, то заканчиваем
        if_equal text[si], 36, end_compare
       
        ; сравнили с пробелом 
        if_equal text[si], 32, found_space
        mov cx, 1
        ;если не пробел, то идем дальше
        inc si
        inc di
        jmp compare

        found_space:
       
        ; если предыдуший не был пробелом
        if_not_equal text[si-1], 32, inc_sum

        inc si
        jmp compare

        inc_sum:
        ; тогда можно прибавлять
        inc bx
        mov cx, 0
        inc si
        inc di
        jmp compare
        
    end_compare:
    
    add bx, cx
    ;mov text[di], '$'
endm

mode equ 1 ; 0 - ввод с клавиатуры, 1 - уже готовая строка

def_mode macro
    ife mode
        create_text macro
            text db 100, 100, 102 dup('$')
        endm
        input_text macro
            print instr1
            input text
        endm
    else
        create_text macro
            text db 13, 13, '  e e e e e e e e e e e e e  ewrererwr  r r ew rwe rew r w rwe r we rew r      rrrrrrrrrrrrrrrrrrrrrrr   rrerqewrewq   $'
        endm
        input_text macro
        endm
    endif
endm