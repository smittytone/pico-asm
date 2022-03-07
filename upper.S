.global to_upper

to_upper:   push {r4-r5}
            mov r4, r1
loop:       ldrb r5, [r0]
            add r0, #1
            cmp r5, #'z'
            bgt cont
            cmp r5, #'a'
            blt cont
            sub r5, #('a'-'A')
cont:       strb r5, [r1]
            add r1, #1
            cmp r5, #0
            bne loop
exit:       pop {r4-r5}
            bx LR