.text
.globl main

main:
    # Setup Stack Frame
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)

    # Inisialisasi a = 2325 dan b = 71
    lui s0, 0x1          # Load Upper Immediate (bagian atas 2325)
    addi s0, s0, -1771   # Koreksi agar jadi 2325 (0x915). 
                         # Note: 0x1000 - 1771 (desimal) = 2325? Cek di Venus nanti.
                         # Sebenarnya: li s0, 2325 lebih aman, tapi ikuti modul.
    addi s1, zero, 71    # b = 71

    # Call division(a, b)
    addi a0, s0, 0       # arg1 = a
    addi a1, s1, 0       # arg2 = b
    jal ra, division
    addi s2, a0, 0       # Simpan hasil div di s2

    # Call remainder(a, b)
    addi a0, s0, 0       # arg1 = a
    addi a1, s1, 0       # arg2 = b
    jal ra, remainder
    sw a0, 12(sp)        # Simpan hasil rem di stack

    # Call multiply(b, div)
    addi a0, s1, 0       # arg1 = b
    addi a1, s2, 0       # arg2 = div
    jal ra, multiply

    # Validasi: Check if (multiply_result + rem) == a
    lw t0, 12(sp)        # Load rem dari stack
    add t1, a0, t0       # t1 = multiply_result + rem
    sub t2, t1, s0       # t2 = calculated_total - a

    # Set return value (1 if match, 0 if not)
    sltiu a0, t2, 1      # Jika t2 < 1 (artinya t2 == 0), maka a0 = 1

    # Restore Stack & Return
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    jalr zero, ra, 0

multiply:
    addi t0, zero, 0     # y = 0
    addi t1, zero, 0     # i = 0
multiply_loop:
    bge t1, a1, multiply_end
    add t0, t0, a0       # y += a
    addi t1, t1, 1       # i++
    jal zero, multiply_loop
multiply_end:
    addi a0, t0, 0
    jalr zero, ra, 0

division:
    addi t0, zero, 0     # y = 0
    addi t1, a0, 0       # i = a
division_loop:
    blt t1, a1, division_end
    sub t1, t1, a1       # i -= b
    addi t0, t0, 1       # y++
    jal zero, division_loop
division_end:
    addi a0, t0, 0
    jalr zero, ra, 0

remainder:
    addi t0, a0, 0       # y = a
remainder_loop:
    blt t0, a1, remainder_end
    sub t0, t0, a1       # y -= b
    jal zero, remainder_loop
remainder_end:
    addi a0, t0, 0
    jalr zero, ra, 0