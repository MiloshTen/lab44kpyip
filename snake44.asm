.model small
.stack 100h

.data

snake dw 512 DUP(0)
tail dw 4
ten dw 10
two dw 2
fruit dw 0
movement dw 4
eighty dw 80
map_size dw 1920
speed dw 0ffffh
count dw 0
str_menu db "1.Play2.Option3.Exit"
str_option db "1.Easy2.Medium3.Hard"

.code

check_fruit proc
mov ax, -1
mov dx, fruit
mov cx, tail
mov si, offset snake
for10:
cmp [si], dx
je end_for10
loopnz for10
mov ax, 0
end_for10:

ret
check_fruit endp

get_fruit proc

mov ah, 0
int 1Ah

mov ax, dx
mov dx, 0
div map_size

mov ax, 1111111111111110b
and dx, ax

mov fruit, dx
call check_fruit
cmp ax, -1
je get_fruit
mov di, fruit
mov es:di, '*'
inc di
mov es:di, 00001100b
ret
get_fruit endp

show_count proc
mov cx, 3
mov ax, count
mov di, 1924
for12:
mov dx, 0
div ten
add dl, '0'
mov es:di, dx
inc di
mov es:di, 00001111b
sub di, 3
loopnz for12
ret
show_count endp

clear proc
mov ah, 0
mov al, 1
int 10h
ret
clear endp

draw_snake proc
mov si, offset snake
mov cx, tail
for7:
mov di, [si]
mov es:di, '0'
inc di
mov es:di, 00001010b
add si, 2
loopnz for7
end_for7:

ret
draw_snake endp

go proc
mov si, offset snake
mov ax, 0
mov cx, tail
for6:
mov di, [si]
mov es:di, ax
add si, 2
loopnz for6
end_for6:
mov si, offset snake
mov ax, [si]
add si, 2
mov cx, tail
dec cx
for3:
xchg ax, [si]
add si, 2
loopnz for3
end_for3:
ret
go endp

create_snake proc
mov ax, 840
mov si, offset snake
mov cx, 4
for4:
mov [si], ax
add si, 2
sub ax, 2
loopnz for4
mov ax, 4
mov tail, ax
ret
create_snake endp

move proc
mov si, offset snake
mov ax, [si]
mov cx, [si]
mov dx, 0
div eighty
mov bx, movement
cmp bx, 1
je up
cmp bx, 2
je down
cmp bx, 3
je left
cmp bx, 4
je right

up:
sub cx, 80
cmp ax, 0
jg en
add cx, 1920
jmp en
down:
add cx, 80
cmp ax, 23
jl en
sub cx, 1920
jmp en
left:
sub cx, 2
cmp dx, 0
jg en
add cx, 80
jmp en
right:
add cx, 2
cmp dx, 78
jl en
sub cx, 80
jmp en

en:
mov [si], cx
ret
move endp

check proc
mov si, offset snake
mov ax, [si]
add si, 2
mov cx, tail
dec cx
for11:
cmp [si], ax
je err
add si, 2
loopnz for11
end_for11:

cmp fruit, ax
jne en2
call get_fruit

inc count
call show_count

inc tail
jmp en2

err:
mov ax, -1
en2:
ret
check endp

switch proc

mov ah, 1
int 16h
jz no_switch
mov ah, 0
int 16h
cmp ah, 048h
je caseW
cmp ah, 04dh
je caseD
cmp ah, 050h
je caseS
cmp ah, 04bh
je caseA
cmp ah, 01h
je escp
jmp def

caseW:
mov ax, 1
end_caseW:
jmp def

caseA:
mov ax, 3
end_caseA:
jmp def

caseS:
mov ax, 2
end_caseS:
jmp def

caseD:
mov ax, 4
end_caseD:
jmp def

escp:
mov ax, -1
no_switch:
mov ax, movement
def:
mov movement, ax
ret
switch endp

for8:
movsb
mov es:di, 00001111b
inc di
loopnz for8
end_for8:
ret

help proc
mov di, 0
mov cx, 6
call for8
mov di, 80
mov cx, 8
call for8
mov di, 160
mov cx, 6
call for8
ret
help endp

menu proc
call clear
mov si, offset str_menu
call help


m:
mov ah, 0
int 16h
cmp ah, 02h
jne no_play
call play
jmp menu
no_play:
cmp ah, 03h
jne no_option
call option
jmp menu
no_option:
cmp ah, 04h
jne m
end_m:

ret
menu endp

option proc
mov si, offset str_option
call help
mov ah, 0
int 16h

p:
cmp ah, 02h
jne no_easy
mov ax, 0ffffh
jmp end_p
no_easy:
cmp ah, 03h
jne no_medium
mov ax, 0eeeeh
jmp end_p
call option
no_medium:
cmp ah, 04h
jne option
mov ax, 0000h
end_p:
mov speed, ax
ret
option endp

play proc
mov ax, 4
mov movement, ax
mov ax, 0
mov count, ax
call clear
call create_snake
call get_fruit
for5:
mov ah, 86h
mov cx, 01h
mov dx, speed
int 15h
call check
cmp ax, -1
je end_for5
call switch
call go
call move
call draw_snake
jmp for5
end_for5:
ret
 
play endp

start:
mov ax, @data
mov ds, ax
mov ax, 0b800h
mov es, ax

mov ah, 0
mov al, 1
int 10h

call menu

mov ah, 0
mov al, 2
int 10h

mov ax, 4C00h
int 21h
end start