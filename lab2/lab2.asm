assume CS:code,DS:data

data segment
len DW 6
arr DW 1, -2, 3, -4, 5, 6
res dw ?
data ends
code segment
start:
        mov AX, data
        mov DS, AX
        mov CX, len
        mov DI, 0
    loop1:
        mov AX,arr[SI]
        CMP AX, 0
        jle skip
        add DI, AX
        skip:
            add SI, 2
        loop loop1
    mov res, DI
    mov AX,4C00H
    int 21h
    code ends
end start