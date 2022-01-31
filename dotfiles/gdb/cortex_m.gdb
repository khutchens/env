# vim: syntax=gdb

# cortex-m hardfault backtrace
define hookpost-backtrace
    if (($lr & 0xffffff00) == 0xffffff00) && (($lr & 0x1) == 0x1)
        # cache register values so they can be restored
        set $sp_cache = $sp
        set $lr_cache = $lr
        set $pc_cache = $pc

        echo \nException detected, pre-signal-handler frames above may not be valid.\n
        if $lr_cache & 0x4
            echo Performing backtrace on PSP:\n
            set $stack = (void**)$psp
        else
            echo Performing backtrace on MSP:\n
            set $stack = (void**)$msp
        end

        # cache stacked register so they can be accessed after SP is clobbered
        set $lr_stacked = *($stack + 5)
        set $pc_stacked = *($stack + 6)
        set $psr_stacked = *($stack + 7)

        set $stack_offset_cpu = 4*8

        # exception stack alignment. this is constant across CPUs
        if (unsigned int)$psr_stacked & 0x200
            set $stack_offset_exception_align = 4
        else
            set $stack_offset_exception_align = 0
        end

        # adjust SP to pre-fault stack frame
        set $sp = $stack + $stack_offset_cpu + $stack_offset_exception_align

        # adjust other core regs
        set $pc = $pc_stacked
        set $lr = $lr_stacked

        bt

        # restore core regs
        set $pc = $pc_cache
        set $sp = $sp_cache
        set $lr = $lr_cache
    end
end

define fault_cm7
    set $fs=(uint32_t*)$r0
    set $fse=(uint32_t*)$r1
    printf "Pre-fault state(frame: 0x%08x):\n", $fs
    printf "R0 = 0x%08x, R1 = 0x%08x, R2 = 0x%08x, R3 = 0x%08x\n", $fs[0], $fs[1], $fs[2], $fs[3]
    printf "R4 = 0x%08x, R5 = 0x%08x, R6 = 0x%08x, R7 = 0x%08x\n", $fse[0], $fse[1], $fse[2], $fse[3]
    printf "R8 = 0x%08x, R9 = 0x%08x, R10= 0x%08x, R11= 0x%08x\n", $fse[4], $fse[5], $fse[6], $fse[7]
    printf "R12= 0x%08x\n\n", $fs[4]
    printf "LR  = 0x%08x\n", $fs[5]
    printf "PC  = 0x%08x\n", $fs[6]
    printf "xPSR= 0x%08x\n", $fs[7]
    printf "E   = 0x%08x\n", $fse[8]
    info line *(void*)$fs[6]
    printf "\n"

    echo Fault status:
    set $cfsr = *(uint32_t*)0xe000ed28
    set $hfsr = *(uint32_t*)0xe000ed2c

    set $mmfar = *(uint32_t*)0xe000ed34
    set $bfar = *(uint32_t*)0xe000ed38

    #CFSR
    if $cfsr != 0x0000
        printf "\nCFSR: 0x%08x (UFSR, BFSR, MMFSR packed together)\n", $cfsr

        # UFSR
        set $ufsr = ($cfsr >> 0x10) & 0xffff
        if $ufsr != 0x0000
            printf "\nUFSR: 0x%04x\n", $ufsr

            if($ufsr & 0xfc00)
                echo Reserved bit!\n
            end
            if($ufsr & 0x0200)
                echo UsageFault[DIVBYZERO]: Divide by zero.\n
            end
            if($ufsr & 0x0100)
                echo UsageFault[UNALIGNED]: Unaligned access.\n
            end
            if($ufsr & 0x00f0)
                echo Reserved bit!\n
            end
            if($ufsr & 0x0008)
                echo UsageFault[NOCP]: No coprocessor.\n
            end
            if($ufsr & 0x0004)
                echo UsageFault[INVPC]: Invalid PC load.\n
            end
            if($ufsr & 0x0002)
                echo UsageFault[INVSTATE]: Invalid state.\n
            end
            if($ufsr & 0x0001)
                echo UsageFault[UNDEFINSTR]: Undefined instruction.\n
            end
        end
        # BFSR
        set $bfsr = ($cfsr >> 0x8) & 0xff
        if $bfsr != 0x00
            printf "\nBFSR: 0x%02x\n", $bfsr

            if($bfsr & 0x80)
                printf "BFSR fault address: 0x%08x\n", $bfar
            end
            if($bfsr & 0x40)
                echo Reserved bit!\n
            end
            if($bfsr & 0x20)
                echo BusFault[LSPERR]: Fault during floating-point lazy state preservation.\n
            end
            if($bfsr & 0x10)
                echo BusFault[STKERR]: BusFault on stacking for exception entry.\n
            end
            if($bfsr & 0x08)
                echo BusFault[UNSTKERR]: BusFault on unstacking for a return from exception.\n
            end
            if($bfsr & 0x04)
                echo BusFault[IMPRECISERR]: Imprecise data bus error, stack context not relevant.\n
            end
            if($bfsr & 0x02)
                echo BusFault[PRECISERR]: Precise data bus error.\n
            end
            if($bfsr & 0x01)
                echo BusFault[IBUSERR]: Instruction bus error.\n
            end
        end

        # MMFSR
        set $mmfsr = $cfsr & 0xff
        if $mmfsr != 0x00
            printf "\nMMFSR: 0x%02x\n", $mmfsr

            if($mmfsr & 0x80)
                printf "MMFSR fault address: 0x%08x\n", $mmfar
            end
            if($mmfsr & 0x40)
                echo Reserved bit!\n
            end
            if($mmfsr & 0x20)
                echo MemManageFault[MLSPERR]: Fault during floating-point lazy state preservation\n
            end
            if($mmfsr & 0x10)
                echo MemManageFault[MSTKERR]: MemManage fault on stacking for exception entry.\n
            end
            if($mmfsr & 0x08)
                echo MemManageFault[MUNSTKERR]: MemManage fault on unstacking for a return from exception.\n
            end
            if($mmfsr & 0x04)
                echo Reserved bit!\n
            end
            if($mmfsr & 0x02)
                echo MemManageFault[DACCVIOL]: Data access violation.\n
            end
            if($mmfsr & 0x01)
                echo MemManageFault[IACCVIOL]: Instruction access violation.\n
            end
        end
    end

    # HFSR
    if $hfsr != 0x00
        printf "\nHFSR: 0x%02x\n", $hfsr

        if($hfsr & 0x40000000)
            echo HardFault[FORCED]: Fault escalated to a hard fault.\n
        end
        if($hfsr & 0x00000002)
            echo HardFault[VECTTBL]: Bus error on a vector read.\n
        end
    end
end

#define hook-stop
#    set $cfsr = *(uint32_t*)0xe000ed28
#    set $hfsr = *(uint32_t*)0xe000ed2c
#
#    if $cfsr || $hfsr
#        fault_cm7
#        echo \n
#    end
#end
