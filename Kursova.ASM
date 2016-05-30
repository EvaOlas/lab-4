MODEL SMALL
.STACK 100h
.386
.DATA

mesn db "Enter n $"
mese db "Enter element $"
mes db "Check the number $"
mesend db "Press any key to exit...$"
mesindex db "Finded element staying here = $"
mesne db "Element isn't finded $"
mesfind db "Finded element = $"
in_menu db "Input:",10,13,"k-keyboard",10,13,"f-file $"
error_input db "Error input $"
infile_name db "Array.txt",0
outfile_name db "Result.txt",0
open_error db "Open error $"
read_error db "Read error $"
write_error db "Write error $"
close_error db "Close error $"
create_error db "Create error $"
fmesfind db 'Find element = ',0
fmesindex db 'Finded element staying here = ',0
fmesne db "Element isn't finded",13,10,0
newline db 13,10,0
inhandle dw 1
outhandle dw 1
endline db 10,13,'$'
Arr dw 100 dup(?)
buffer db 32 dup(0)
Str1 dw 100 dup(0)
n dw 0
sortn dw 0
bool db 0
Out_str db 250 dup(0)
position dw 0
menu_buf db 5 dup(0)
index dw -1



.CODE
;----------------------
exit proc near
     mov ah,08h
     int 21h
     mov ax,4C00h
     int 21h
exit endp
;----------------------
endl proc near
     push ax
     push dx
     mov ah,09h
     mov dx,OFFSET endline
     int 21h
     pop dx
     pop ax
ret
endl endp
;-----------------------
error proc near
     call endl
     mov ah,09h
     mov dx,OFFSET mes
     int 21h
     call endl
     call endl
     mov ah,09h
     mov dx,OFFSET mesend
     int 21h
     call exit
error endp
;-----------------------
;in
;si-adres str
;out
;ax-number
StrToInt proc near
    push bx
    xor bx,bx
    xor ax,ax
    mov al,[si]
    cmp al,'-'
    jne m10
    mov [bool],1
    inc si
    m10:
    xor ax,ax
    m1:
	mov bh,10
	imul bh
	mov bl,[si]
	cmp bl,'0'
	jl error
	cmp bl,'9'
	jg error
	sub bl,30h
	xor bh,bh
	add ax,bx
	inc si
	mov bh,[si]
	cmp bh,0Dh
	jne m1
	cmp [bool],0
	je m9
	neg ax
	m9:
	pop bx
    mov [bool],0
    ret
StrToInt endp
;-----------------------
;bx-handle
close_file proc near
    push ax
    mov ah,3Eh
    int 21h
  jnc lb16
    mov ah,09h
    mov dx,OFFSET close_error
    int 21h
    jmp exit
  lb16:
    pop ax
ret
close_file endp
;-----------------------
;ax-number
Out_number proc near
    push cx
    push bx
    xor cx,cx
    cmp ax,0
    jnl m2
    neg ax;
    push ax;
    mov ah,02h
    mov dx,'-'
    int 21h
    pop ax
    m2:
    mov bh,10
    xor dx,dx
    idiv bh
    push ax
    xor ah,ah
    inc cx
    cmp al,0
    jne m2
    xor dx,dx
    m3:
    pop ax
    add ah,30h
    mov dl,ah
    mov ah,02h
    int 21h
    loop m3
    pop bx
    pop cx
ret
Out_number endp
;-----------------------
;in
;si-adres bufera
;al-count of numbers
;out
;si-adres str
InStr1 proc near
     push dx
     mov [si],al
     xor ax,ax
     mov [si+1],al
     mov ah,0ah
     mov dx,si
     int 21h
     add si,2
     pop dx
ret
endp
;-----------------------
;in
;no parametr
;out
;Arr-array
InArr proc near
     push ax
     push cx
     push dx
     push bx
     mov cx,[n]
     xor bx,bx
     add bx,2
   inarr1:
     mov ah,09h
     mov dx,OFFSET mese
     int 21h
     mov al,5
     lea si,buffer
     call InStr1
     call StrToInt
     mov word ptr[Arr+bx],ax
     add bx,2
     call endl
   loop inarr1
     pop bx
     pop dx
     pop cx
     pop ax
ret
InArr endp
;-----------------------
;no parametr
OutArr proc near
     push ax
     push cx
     push dx
     push bx
     mov cx,[n]
     xor bx,bx
     add bx,2
   outarr1:
     mov ax,[Arr+bx]
     call Out_number
     mov ah,02h
     mov dx,' '
     int 21h
     int 21h
     add bx,2
   loop outarr1
     call endl
     pop bx
     pop dx
     pop cx
     pop ax
ret
OutArr endp
;-----------------------
;ax-number
IntToStr proc near
    push cx
    push bx
    push dx

    xor bx,bx
    mov bx,[position]
    xor cx,cx
    cmp ax,0
    jnl m2f
    neg ax;
    mov [Out_str+bx],'-'
    inc bx
  m2f:
    mov dh,10
    idiv dh
    push ax
    xor ah,ah
    inc cx
    cmp al,0
    jne m2f
    xor dx,dx
  m3f:
    pop ax
    add ah,30h
    mov [Out_str+bx],ah
    inc bx
  loop m3f
    mov [Out_str+bx],' '
    inc bx
    mov [position],bx

    pop dx
    pop bx
    pop cx
ret
IntToStr endp
;-----------------------
;dx-mes
Out_Arrf proc near
    push ax
    push bx
    push cx

    mov bx,[outhandle]
    mov ah,40h
    mov dx,OFFSET fmesfind
    mov cx,15 ;-------------------------------
    int 21h
  jnc lb10
    mov ah,09h
    mov dx,OFFSET write_error
    int 21h
    jmp exit
  lb10:
    mov ax,[Arr]
    call IntToStr
    mov bx,[position]
    mov [Out_str+bx],13
    inc bx
    mov [Out_str+bx],10
    inc bx
    mov [position],bx
    mov bx,[outhandle]
    mov ah,40h
    mov dx,OFFSET Out_str
    mov cx,[position]
    int 21h
  jnc lb11
    mov ah,09h
    mov dx,OFFSET write_error
    int 21h
    jmp exit
  lb11:
    mov [position],0
    xor ax,ax
    cmp ax,[index]
  jg nfind
    mov bx,[outhandle]
    mov ah,40h
    mov dx,OFFSET fmesindex
    mov cx,30 ;-------------------------------
    int 21h
  jnc lb12
    mov ah,09h
    mov dx,OFFSET write_error
    int 21h
    jmp exit
  lb12:
    mov ax,[index]
    call IntToStr
    mov bx,[position]
    mov [Out_str+bx],13
    inc bx
    mov [Out_str+bx],10
    inc bx
    mov [position],bx
    mov bx,[outhandle]
    mov ah,40h
    mov dx,OFFSET Out_str
    mov cx,[position]
    int 21h
  jnc lb13
    mov ah,09h
    mov dx,OFFSET write_error
    int 21h
    jmp exit
  lb13:
    mov [position],0
  jmp lb14
  nfind:
    mov bx,[outhandle]
    mov ah,40h
    mov dx,OFFSET fmesne
    mov cx,22 ;-------------------------------
    int 21h
  jnc lb14
    mov ah,09h
    mov dx,OFFSET write_error
    int 21h
    jmp exit
  lb14:
    xor bx,bx
    xor cx,cx
    mov cx,[n]
    add bx,2

    writeloop:
	mov ax,[Arr+bx]
	call IntToStr
	add bx,2
    loop writeloop


    mov bx,[position]
    mov [Out_str+bx],13
    inc bx
    mov [Out_str+bx],10
    inc bx
    mov [position],bx
    mov bx,[outhandle]
    mov ah,40h
    mov dx,OFFSET Out_str
    mov cx,[position]
    int 21h
  jnc lb15
    mov ah,09h
    mov dx,OFFSET write_error
    int 21h
    jmp exit
  lb15:
    mov [position],0
    pop cx
    pop bx
    pop ax
ret
Out_Arrf endp
;-----------------------
;in
;no parametr
;out
;Arr-array
;n-count of numbers
in_file proc near
     push ax
     push bx
     push cx
     push dx
     push si

     mov ah,3Dh
     xor al,al
     mov dx,OFFSET infile_name
     xor cx,cx
     int 21h
     jnc lb5
     mov ah,09h
     mov dx,OFFSET open_error
     int 21h
     jmp exit
   lb5:mov [inhandle],ax

     mov bx,[inhandle]
     mov ah,3Fh
     lea dx,buffer
     mov cx,250;       250 charactars
     int 21h
     jnc lb6
     mov ah,09h
     mov dx,OFFSET read_error
     int 21h
     jmp exit
   lb6:lea bx,buffer
     add bx,ax
     mov BYTE PTR[bx],'$'
     call endl
     mov bx,[inhandle]
     call close_file

     lea si,buffer
     xor bx,bx
     mov di,Str1
     mov al,[si]
     cmp al,'$'
   je endproc
   scaning:
     cmp al,'-'
     jne lb7
     cmp di,Str1
     je write
     jmp error
   lb7:
     cmp al,'0'
     jl lb8
     cmp al,'9'
     jg lb8
   write:
     mov [di],al
     inc si
     inc di
     mov al,[si]
     jmp scaning
   lb8:cmp al,' '
     jne lb9
     cmp di,Str1
     jne noscaning
     inc si
     mov al,[si]
     jmp scaning
     noscaning:
     mov byte ptr[di],0Dh
     inc si
     mov di,Str1
     push si
     mov si,Str1
     call StrToInt
     pop si
     mov [Arr+bx],ax
     mov al,[si]
     add bx,2
     jmp scaning
   lb9:cmp al,'$'
     jne error
     xor ax,ax
     cmp al,byte ptr[Str1]
   je endproc
   cmp di,Str1
   je endproc
     mov si,Str1
     call StrToInt
     mov [Arr+bx],ax
     add bx,2
   endproc:
     cmp bx,0
     je error
     shr bx,1
     dec bx
     mov [n],bx

     pop si
     pop dx
     pop cx
     pop bx
     pop ax
ret
in_file endp
;----------------------------
     start:
     mov ax,@data
     mov ds,ax

     inmenu:
     mov ah,09h
     mov dx, OFFSET in_menu
     int 21h
     mov [menu_buf],2
     mov [menu_buf+1],0 ;Input mes
     lea dx,menu_buf
     mov ah,0ah
     int 21h

     mov al,[menu_buf+2]
     cmp al,'k'
     jne lb1
     jmp in_keaboard
   lb1:mov al,[menu_buf+2]
     cmp al,'f'
     jne lb2
     call in_file
     jmp main
   lb2:
     call endl
     mov ah,09h
     mov dx,OFFSET error_input
     int 21h
     call endl
     jmp inmenu
   in_keaboard:
     call endl
     mov ah,09h ; enter n
     mov dx,OFFSET mesn
     int 21h
     lea si,buffer
     mov al,10
     call InStr1
     call StrToInt
     call endl
     mov [n],ax

     call InArr
     mov ah,09h
     mov dx,OFFSET mesfind
     int 21h
     lea si,buffer
     mov al,5
     call InStr1
     call StrToInt
     mov [Arr],ax
     call endl

   main:
     mov ax,[Arr]
     mov cx,[n]
     xor bx,bx
     add bx,2
     find:
	  cmp ax,[Arr+bx]
	  jne next
	  mov ax,bx
	  shr ax,1
	  mov [index],ax
	  jmp endfind
	  next:
	  add bx,2
     loop find
   endfind:



     mov al,[menu_buf+2]
     cmp al,'k'
   jne lb3
     xor ax,ax
     cmp ax,[index]
     jl jump
     mov ah,09h
     mov dx,OFFSET mesne
     int 21h
     call endl
     jmp endpr
   jump:
     mov ah,09h
     mov dx,OFFSET mesindex
     int 21h
     mov ax,[index]
     call Out_number
     call endl
     call OutArr
   lb3:
     mov al,[menu_buf+2]
     cmp al,'f'
   jne endpr
     mov ah,3Ch
     mov dx,OFFSET outfile_name
     xor cx,cx
     int 21h
   jnc lb4
     mov ah,09h
     mov dx,OFFSET create_error
     int 21h
     jmp exit
   lb4:mov [outhandle],ax

     call Out_Arrf
     mov bx,[outhandle]
     call close_file
   endpr:
     call endl
     mov ah,09h
     mov dx,OFFSET mesend
     int 21h
   call exit
END start

;in
;no parametr
;out
;Arr-array
InArr:
     push ax
     push cx
     push dx
     push bx
     mov cx,[n]
     xor bx,bx
     add bx,2
   inarr1:
     mov ah,09h
     mov dx,OFFSET mese
     int 21h
     mov al,5
     mov si,buffer
     call InStr1
     call StrToInt
     mov [Arr+bx],ax
     add bx,2
     call endl
   loop inarr1
     pop bx
     pop dx
     pop cx
     pop ax
ret














