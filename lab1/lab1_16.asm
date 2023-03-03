
assume CS:code,DS:data

data segment
msg db ?,?,'$'
a db 3
b db 6
c db 4
d db 2
res1 db ?
res2 db ?

data ends

code segment
start:
mov AX, data
mov DS, AX
mov AH,0
mov Al,a   
mul c
mov res1, Al ;res1 = a * c
mov AX, 0
mov Al, b
mov bl, d
div bl
add AL, res1
inc AL
mov res1, Al

mov AH, 0
mov bx, 10
xor dx, dx
div bx
add dl, '0'
push dx
inc cx
xor dx, dx
div bx
add dl, '0'
push dx
inc cx
pop dx
mov [di],dl
inc di
pop dx 
mov [di],dl
inc di

mov AH,09h
mov DX, offset msg
int 21h
mov AX,4C00H
int 21h

code ends
end start
