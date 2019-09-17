org 0x500
jmp 0x0000:start


line1 db 'Loading structures for the kernel...',0
line2 db 'Setting up protected mode...', 0
line3 db 'Loading kernel in memory...', 0
line4 db 'Running kernel!', 0
final db ' ', 0

str1 db 'Retornando a tempos perdidos',0
str2 db 'Entrando no desconhecido', 0
str4 db 'Aprendendo a escrever', 0
str5 db 'Expulsando os espanhois', 0
dot db '.', 0
finalDot db '.', 10, 13, 0

start:
    mov bl, 3 ; Seta cor dos caracteres para verde
	call limpaTela
	
	mov si, line1
	call printString
	call printDots
	
	mov si, line2
	call printString
	call printDots
	
	mov si, line3
	call printString
	call printDots
	
	mov si, line4
	call printString
	call printDots
	
	mov bl, 6 ; Seta cor dos caracteres para verde
	call limpaTela
	
	mov si, str1
	call printString
	call printDots

	mov si, str2
	call printString
	call printDots

	mov si, str4
	call printString
	call printDots

	mov si, str5
	call printString
	call printDots 

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

limpaTela:
;; Limpa a tela dos caracteres colocados pela BIOS
	; Set the cursor to top left-most corner of screen
	mov dx, 0 
    mov bh, 0      
    mov ah, 0x2
    int 0x10

    ; print 2000 blanck chars to clean  
    mov cx, 2000 
    mov bh, 0
    mov al, 0x20 ; blank char
    mov ah, 0x9
    int 0x10
    
    ;Reset cursor to top left-most corner of screen
    mov dx, 0 
    mov bh, 0      
    mov ah, 0x2
    int 0x10
ret

newLine:
    mov al, 10
    mov ah, 0eh
    int 10h
    mov al, 13
    mov ah, 0eh
    int 10h
ret

printString: 
;; Printa a string que esta em si    
	
	lodsb
	cmp al, 0
	je exit

	mov ah, 0xe
	int 10h	

	mov dx, 50;tempo do delay
	call delay 
	
	jmp printString
exit:
ret

delay: 
;; Função que aplica um delay(improvisado) baseado no valor de dx
	mov bp, dx
	back:
	dec bp
	nop
	jnz back
	dec dx
	cmp dx,0    
	jnz back
ret

printDots:
;; Printa os pontos das reticências
	mov cx, 2

	for:
		mov si, dot
		call printString
		mov dx, 600
		call delay
	dec cx
	cmp cx, 0
	jne for

	mov dx, 1200
	call delay
	mov si, finalDot
	call printString
	
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
