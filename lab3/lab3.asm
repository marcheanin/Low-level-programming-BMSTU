assume cs: code, ds: data

data segment
msg db ?,?,'$'
vara db 1
string1 db 100, 99 dup (0)
string2 db 100, 99 dup (0)
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


strcspn proc
    push bp
    mov bp, sp
    mov si,[bp+6] ;string1
    mov di,[bp+4] ;string2
    ;mov si, offset string
    xor cx,cx
    mov cl, [si +1]
    xor ax, ax; сюда результат
    mov dx, si
    add si, 2
    loop1:
        mov bx, cx
        ;cmp si, cx
        ;je endloop1
        mov di, [bp+4]
        mov cl, [di + 1] ;;;
        add di, 2
        loop2:
            mov ah, [si]
            mov al, [di]
            ;cmp byte [si], byte [di]
            cmp ah, al
            je endloop1 
            inc di
            loop loop2
        mov cx, bx
        inc si
    loop loop1
    endloop1:
    mov ax, si
    sub ax, dx
    sub ax, 2

    pop bp
    pop bx
    push ax; положили ответ
    push bx
    ret
strcspn endp

start: 
    mov ax, data
    mov ds, ax
    mov dx, offset dest
    push dx
    xor dx, dx
    ;считывание первой строки
    mov dx, offset string1
    mov ax, 0
    mov ah, 0Ah
    int 21h
    mov bl, [string1 + 1]
    inc bl
    mov si, bx
    mov byte[string1 + si],'$'
    push dx

    mov ax, 03;очистка консоли
    int 10h;
    ;считывание второй строки
    xor bx, bx
    mov dx, offset string2
    mov ax, 0
    mov ah, 0Ah
    int 21h
    mov bl, [string2 + 1]
    inc bl
    mov si, bx
    mov byte[string2 + si],'$'
    push dx

    mov ax, 03;очистка консоли
    int 10h;

    call strcspn
    pop dx
    ;cmp dx, 0
    ;jne start
    add dl, '0'
    xor di, di
    mov [di],dl
    mov AH,09h
    mov DX, offset msg
    int 21h
    ;mov AX,4C00H
    
    mov ah, 4ch
    int 21h
code ends
end start