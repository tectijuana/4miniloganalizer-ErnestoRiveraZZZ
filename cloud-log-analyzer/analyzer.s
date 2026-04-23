.section .data
    msg_2xx: .ascii "Exitos (2xx): "
    len_2xx = . - msg_2xx
    msg_4xx: .ascii "Errores cliente (4xx): "
    len_4xx = . - msg_4xx
    msg_5xx: .ascii "Errores servidor (5xx): "
    len_5xx = . - msg_5xx
    newline: .ascii "\n"

.section .bss
    buffer: .space 1024
    num_str: .space 20

.section .text
.global _start

_start:
    // Inicializar contadores
    mov x19, 0          // Contador 2xx
    mov x20, 0          // Contador 4xx
    mov x21, 0          // Contador 5xx
    mov w22, 1          // Bandera de inicio de línea

read_loop:
    // Syscall: read(stdin)
    mov x0, 0           // fd 0 (stdin)
    ldr x1, =buffer
    mov x2, 1024
    mov x8, 63          // syscall read
    svc 0

    cmp x0, 0
    ble print_results   // Si leemos 0 o menos, EOF, vamos a imprimir

    mov x3, x0          // Bytes leídos
    ldr x4, =buffer     // Puntero al buffer

process_buffer:
    ldrb w5, [x4], 1    // Leer 1 byte
    subs x3, x3, 1

    cmp w5, 10          // ¿Es '\n'?
    beq set_newline

    cmp w22, 1          // ¿Estamos al inicio de la línea?
    bne next_byte

    cmp w5, '2'
    beq count_2xx
    cmp w5, '4'
    beq count_4xx
    cmp w5, '5'
    beq count_5xx
    b clear_flag

count_2xx:
    add x19, x19, 1
    b clear_flag
count_4xx:
    add x20, x20, 1
    b clear_flag
count_5xx:
    add x21, x21, 1
    b clear_flag

clear_flag:
    mov w22, 0
    b next_byte

set_newline:
    mov w22, 1

next_byte:
    cmp x3, 0
    bgt process_buffer
    b read_loop

print_results:
    // Imprimir mensaje 2xx
    mov x0, 1
    ldr x1, =msg_2xx
    mov x2, len_2xx
    mov x8, 64
    svc 0
    mov x0, x19
    bl print_number

    // Imprimir mensaje 4xx
    mov x0, 1
    ldr x1, =msg_4xx
    mov x2, len_4xx
    mov x8, 64
    svc 0
    mov x0, x20
    bl print_number

    // Imprimir mensaje 5xx
    mov x0, 1
    ldr x1, =msg_5xx
    mov x2, len_5xx
    mov x8, 64
    svc 0
    mov x0, x21
    bl print_number

exit_program:
    mov x0, 0
    mov x8, 93          // syscall exit
    svc 0

// Subrutina para imprimir un número entero almacenado en x0
print_number:
    ldr x1, =num_str
    add x1, x1, 19      // Apuntar al final del buffer
    mov w2, 10          // Salto de línea
    strb w2, [x1]
    mov x3, x1          // Guardar puntero original
    
    cmp x0, 0
    bne convert_loop
    sub x1, x1, 1
    mov w2, '0'
    strb w2, [x1]
    b do_print

convert_loop:
    cmp x0, 0
    beq do_print
    mov x2, 10
    udiv x4, x0, x2     // x4 = x0 / 10
    msub x5, x4, x2, x0 // x5 = x0 - (x4 * 10) -> Residuo
    add w5, w5, '0'     // Convertir a ASCII
    sub x1, x1, 1       // Retroceder puntero
    strb w5, [x1]       // Guardar caracter
    mov x0, x4          // Actualizar cociente
    b convert_loop

do_print:
    mov x0, 1           // stdout
    mov x2, x3          // Calcular longitud
    sub x2, x2, x1
    add x2, x2, 1
    mov x8, 64          // syscall write
    svc 0
    ret
