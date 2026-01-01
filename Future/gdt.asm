; gdt.asm - 纯二进制布局，脱离ELF段校验，彻底无冲突
[bits 16]
[section .text]  ; 仍声明.text段，但内部按物理地址布局
global switch_to_pm
extern kernel_main

; -------------------------- 物理地址布局：GDT在前（0x0000-0x001D），代码在后（0x0020开始） --------------------------
; 无需符号，按物理偏移直接排布，汇编器仅做指令/数据解析，不做段属性校验
align 8
; GDT空描述符（0x0000-0x0007）
dd 0x00000000
dd 0x00000000
; 代码段描述符（0x0008-0x000F）
dw 0xFFFF
dw 0x0000
db 0x00
db 0x9A
db 0xCF
db 0x00
; 数据段描述符（0x0010-0x0017）
dw 0xFFFF
dw 0x0000
db 0x00
db 0x92
db 0xCF
db 0x00
; GDT描述符（0x0018-0x001D）：长度0x17，基地址直接填物理偏移0x0000（链接时自动修正）
dw 0x0017
dd 0x00000000

; 代码区：强制从0x0020开始（物理地址对齐，与GDT彻底隔离）
align 32  ; 更强的对齐，彻底消除偏移衔接冲突
switch_to_pm:
    ; 关闭中断
    cli
    ; 关键：用立即数偏移寻址GDT描述符（物理偏移0x18，不依赖符号）
    lgdt [0x18]
    ; 开启保护模式
    mov eax, cr0
    or eax, 0x01
    mov cr0, eax
    ; 远跳转：直接指定.pm_entry的物理偏移0x38（与列表文件完全匹配）
    jmp dword 0x08:0x38

; 32位保护模式入口（物理偏移0x38）
[bits 32]
.pm_entry:
    ; 初始化数据段寄存器
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ; 设置栈指针（安全物理地址）
    mov esp, 0x90000
    ; 调用内核主函数
    call kernel_main
    ; 无限循环
    jmp $

