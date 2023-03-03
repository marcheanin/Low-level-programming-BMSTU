assume cs: code, ds: data

data segment
vara db 1
string db 100, 99 dup (0)
dest db 100 dup(0)
data ends

code segment
print proc
    push bp
    mov bp, sp

    mov dx, [bp+4]
    add dx, 2
    mov ah, 09h
    int 21h
    pop bp
    pop bx
    xor ax, ax
    push ax
    push bx
    ret
print endp

strcpy proc
    push bp
    mov bp, sp
    mov si,[bp+4]
    mov di,[bp+6]
    xor cx,cx
    mov cl, [si +1]
    add cx, 2
    cld
    rep movsb
    pop bp
    pop bx
    xor ax, ax
    push ax
    push bx
    ret
strcpy endp

start: 
    mov ax, data
    mov ds, ax
    mov dx, offset dest
    push dx
    xor dx, dx
    mov dx, offset string
    mov ax, 0
    mov ah, 0Ah
    int 21h
    mov bl, [string + 1]
    inc bl
    mov si, bx
    mov byte[string + si],'$'
    push dx
    call strcpy
    pop dx
    cmp dx, 0
    jne start
    mov dx, offset dest
    call print
    pop dx
    cmp dx, 0
    jne start

    mov ah, 4ch
    int 21h
code ends
end start