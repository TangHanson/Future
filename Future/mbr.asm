bits 16
org 0x7c00

start:
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    
    mov ah, 0x06
    mov al, 0x00
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184f
    int 0x10
    
    mov ah, 0x0e
    mov si, msg
print_loop:
    lodsb
    or al, al
    jz end_loop
    int 0x10
    jmp print_loop
    
end_loop:
    jmp $

msg: db 'Hello OS!', 0

times 510 - ($ - $$) db 0
dw 0xaa55
