assume CS:code,DS:data
data segment
msg db ?,?,'$'
d dw 16
a db 3
b db 2
c db 5
res dw ?
data ends
code segment
start:
mov AX, data
mov DS, AX
mov AX, 0
mov AL,a
mul b
mul c
mov res, AX
xor AL,AL
mov AX,d
shr AX,3
add res, AX
xor BX, BX
mov BX, res
sub BX,3
mov res,BX
xor BX, BX
xor dx,dx
mov bx, 10
mov AX, res
div bx
add dl,'0'
push dx
inc cx
xor dx,dx
div bx
add dl,'0'
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