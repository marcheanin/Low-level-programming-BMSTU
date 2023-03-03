include macro.asm



def_mode
assume cs: code, ds: data

data segment

create_text
msg db 50 dup(0)


instr1 db 'input your text', 10, 36

newline db 10, 36

data ends

sseg segment stack
db 256 dup(0)
sseg ends

code segment

start:
    ; в программе есть переменная mode 
    ; если mode == 0, то текст вводится с клавиатуры
    ; иначе, он - уже готовая строка

	; начальные настройки
	init

    input_text

    count_words text

    print newline

    ;print text+2

    ;local do, do2
    push ax
    push cx
    xor cx, cx
    xor ax, ax
    mov ax, bx
    xor bx, bx
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

    print msg

	mov ah, 4ch
	int 21h
	code ends
	end start