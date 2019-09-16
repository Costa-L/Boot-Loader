org 0x500
jmp 0x0000:start


line1 db 'Loading structures for the kernel...',0
line2 db 'Setting up protected mode...', 0
line3 db 'Loading kernel in memory...', 0
line4 db 'Running kernel!', 0
final db ' ', 0

start:
    mov bl, 15
    call clear

    step1:
    
        mov cx, 3
        mov si, line1
        call printLine

        call newLine
        
        mov cx,3
        mov si,line2
        call printLine
        
        call newLine
        
        mov cx,3
        mov si,line3
        call printLine
        
        call newLine

        mov cx,3
        mov si,line4
        call printLine
        
        call newLine
        
        mov cx,3
        mov si,final
        call printLine
        
        call newLine
        
        

    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ax, 0x7e0 ;0x7e0<<1 = 0x7e00 (início de kernel.asm)
    mov es, ax
    xor bx, bx    ;posição es<<1+bx

    jmp reset

clear:
    mov ah, 0x2
    mov dx, 0
    mov bh, 0
    int 10h

    mov al, 0x20
    mov ah, 0x9
    mov bh, 0
    mov cx, 1000
    int 10h

    mov bh, 0
    mov dx, 0
    mov ah, 0x2
    int 10h
ret


delay: 
	mov bp, dx
	back:
	dec bp
	nop
	jnz back
	dec dx
	cmp dx,0    
	jnz back
ret

printLine:
    
    lodsb
    cmp al, 0
    je return

    mov ah, 0xe
    int 10h

    mov dx, 1
    call delay

    jmp printLine


return:
ret


newLine:
    mov al, 10
    mov ah, 0eh
    int 10h
    mov al, 13
    mov ah, 0eh
    int 10h
ret

reset:
    mov ah, 00h ;reseta o controlador de disco
    mov dl, 0   ;floppy disk
    int 13h

    jc reset    ;se o acesso falhar, tenta novamente

    jmp load

load:
    mov ah, 02h ;lê um setor do disco
    mov al, 20  ;quantidade de setores ocupados pelo kernel
    mov ch, 0   ;track 0
    mov cl, 3   ;sector 3
    mov dh, 0   ;head 0
    mov dl, 0   ;drive 0
    int 13h

    jc load     ;se o acesso falhar, tenta novamente

    jmp 0x7e00  ;pula para o setor de endereco 0x7e00 (start do kernel)
