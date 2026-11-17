; NBJWLINK 0.0.8 runtime test. Win1-compatible app startup from NOWNGEN.
; This is a test application; NBJWLINK remains independent of application code.
.8086
.model small
.stack 2048

extrn InitTask:far
extrn WaitEvent:far
extrn InitApp:far
extrn MessageBox:far

.data
    db 16 dup (0)
    proofText  db 'NBJWLINK WIN1: 8086 startup and OMF imports',0
    proofTitle db 'NBJWLINK Win1 GUI',0

.code
start:
    ; The proven NOWN real-mode entry contract begins with 8 NOP bytes.
    db 8 dup (090h)
    ; The Win16 loader owns DS/SS/SP on entry; InitTask initializes DS.
    call InitTask
    or ax,ax
    jz quit

    ; Required startup ordering: WaitEvent(0), then InitApp(DI).
    xor ax,ax
    push ax
    call WaitEvent
    push di
    call InitApp
    or ax,ax
    jz quit

    ; FAR PASCAL arguments are pushed left-to-right.
    xor ax,ax
    push ax                  ; HWND 0
    push ds                  ; LPCSTR text segment
    mov ax,offset proofText
    push ax                  ; text offset
    push ds                  ; LPCSTR title segment
    mov ax,offset proofTitle
    push ax                  ; title offset
    xor ax,ax
    push ax                  ; MB_OK
    call MessageBox

quit:
    mov ax,4C00h
    int 21h
end start
