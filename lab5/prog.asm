include macro.asm



def_mode
assume cs: code, ds: data

data segment

create_text
msg db '0','0','$'


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

   ; print text+2

    tostr bx

    print msg

	mov ah, 4ch
	int 21h
	code ends
	end start