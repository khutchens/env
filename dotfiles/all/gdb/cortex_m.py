class CortexM(object):
    #define fault_backtrace
    #    if (($lr & 0xffffff00) == 0xffffff00) && (($lr & 0x1) == 0x1)
    #        # cache register values so they can be restored
    #        set $sp_cache = $sp
    #        set $lr_cache = $lr
    #        set $pc_cache = $pc

    #        echo \nException detected, pre-signal-handler frames above may not be valid.\n
    #        if $lr_cache & 0x4
    #            echo Performing backtrace on PSP:\n
    #            set $stack = (void**)$psp
    #        else
    #            echo Performing backtrace on MSP:\n
    #            set $stack = (void**)$msp
    #        end

    #        # cache stacked register so they can be accessed after SP is clobbered
    #        set $lr_stacked = *($stack + 5)
    #        set $pc_stacked = *($stack + 6)
    #        set $psr_stacked = *($stack + 7)

    #        set $stack_offset_cpu = 4*8

    #        # exception stack alignment. this is constant across CPUs
    #        if (unsigned int)$psr_stacked & 0x200
    #            set $stack_offset_exception_align = 4
    #        else
    #            set $stack_offset_exception_align = 0
    #        end

    #        # adjust SP to pre-fault stack frame
    #        set $sp = $stack + $stack_offset_cpu + $stack_offset_exception_align

    #        # adjust other core regs
    #        set $pc = $pc_stacked
    #        set $lr = $lr_stacked

    #        bt

    #        # restore core regs
    #        set $pc = $pc_cache
    #        set $sp = $sp_cache
    #        set $lr = $lr_cache
    #    end
    #end
    pass

class CortexM4(CortexM):
    pass

class CortexMFaultCmd(gdb.Command):
  def __init__ (self):
    super(CortexMFaultCmd, self).__init__ ("fault", gdb.COMMAND_USER)

  def invoke (self, arg, from_tty):
      print("pc:{} sp:{}".format(pc, sp))

CortexMFaultCmd()

from gdb.unwinder import Unwinder

class FrameId(object):
    def __init__(self, sp, pc):
        self.sp = sp
        self.pc = pc
        self.special = gdb.Value(0x123).cast(gdb.lookup_type("void").pointer())

class CortexMExceptionUnwinder(Unwinder):
    def __init__(self):
        print("__init__({})".format(self))
        super(CortexMExceptionUnwinder, self).__init__("cortex-m-exception")

    def __call__(self, pending_frame):
        print("__call__({})".format(pending_frame))
        #print("arch: {}".format(pending_frame.architecture().name()))
        #print(dir(pending_frame))

        sp = pending_frame.read_register('sp')
        pc = pending_frame.read_register('pc')
        lr = pending_frame.read_register('lr')
        msp = pending_frame.read_register('msp')
        psp = pending_frame.read_register('psp')
        print("frame(pc: {}, sp:{}, lr:{}, t:{})".format(pc, sp, lr, pending_frame.type()))

        def print_val(reg, val):
            print("{}: v:{}, t:{}".format(reg, str(val), val.type))
        print_val("sp", sp)
        print_val("pc", pc)
        print_val("lr", lr)
        print_val("psp", psp)
        print_val("msp", msp)

        t_u32 = gdb.lookup_type("uint32_t")
        t_void = gdb.lookup_type("void")
        t_vptrptr = t_void.pointer().pointer()

        def test_exc_reg(reg):
            r_int = reg.cast(t_u32)
            r_mask = gdb.Value(0xffffffe0).cast(t_u32)
            return ((r_int & r_mask) == (r_mask))

        #if not test_exc_reg(lr):
        if not test_exc_reg(pc):
            print("pass")
            return None

        prev_sp = psp.cast(sp.type) # or msp
        prev_stack = prev_sp.cast(t_vptrptr)

        prev_r0 = (prev_stack + 0).dereference().cast(t_u32)
        prev_r1 = (prev_stack + 1).dereference().cast(t_u32)
        prev_r2 = (prev_stack + 2).dereference().cast(t_u32)
        prev_r3 = (prev_stack + 3).dereference().cast(t_u32)
        prev_r12 = (prev_stack + 4).dereference().cast(t_u32)
        prev_lr = (prev_stack + 5).dereference().cast(lr.type)
        prev_pc = (prev_stack + 6).dereference().cast(pc.type)
        print_val("prev_sp", prev_sp)
        print_val("prev_pc", prev_pc)
        print_val("prev_lr", prev_lr)

        #unwind_info = pending_frame.create_unwind_info(FrameId(prev_sp, prev_pc))
        unwind_info = pending_frame.create_unwind_info(FrameId(sp, pc))
        unwind_info.add_saved_register('sp', prev_sp.cast(t_void.pointer()))
        unwind_info.add_saved_register('r0', prev_r0)
        unwind_info.add_saved_register('r1', prev_r1)
        unwind_info.add_saved_register('r2', prev_r2)
        unwind_info.add_saved_register('r3', prev_r3)
        unwind_info.add_saved_register('r12', prev_r12)
        unwind_info.add_saved_register('lr', prev_lr)
        unwind_info.add_saved_register('pc', prev_pc)
        print("unwind({})".format(unwind_info))
        #print("caller({})".format(pending_frame.older()))
        return unwind_info

        #if not <we recognize frame>:
        #    return None

        ## Create UnwindInfo.  Usually the frame is identified by the stack 
        ## pointer and the program counter.
        #sp = pending_frame.read_register(<SP number>)
        #pc = pending_frame.read_register(<PC number>)
        #unwind_info = pending_frame.create_unwind_info(FrameId(sp, pc))

        ## Find the values of the registers in the caller's frame and 
        ## save them in the result:
        #unwind_info.add_saved_register(<register>, <value>)
        #....

        ## Return the result:
        #return unwind_info

gdb.unwinder.register_unwinder(None, CortexMExceptionUnwinder())

#class LibjitFrameDecorator(FrameDecorator):
#    def __init__(self, base, start, end):
#        super(LibjitFrameDecorator, self).__init__(base)
#        self.start = start
#        self.end = end
#
#    def function(self):
#        return "JIT[0x%x, 0x%x]" % (self.start, self.end)
#
#class LibjitFrameFilter(object):
#    def __init__(self):
#        self.name = "Libjit"
#        self.enabled = True
#        self.priority = 100
#
#    def maybe_wrap(self, frame):
#        rbp = long(frame.inferior_frame().read_register("rbp"))
#        vals = find_by_sp(rbp)
#        if vals is None:
#            return frame
#        return LibjitFrameDecorator(frame, vals[0], vals[1])
#
#    def filter(self, frame_iter):
#        return imap(self.maybe_wrap, frame_iter)
#
#class LibjitUnwinder(gdb.unwinder.Unwinder):
#    def __init__(self):
#        super(LibjitUnwinder, self).__init__("Libjit")
#        self.enabled = True
#
#    def our_frame(self, pc, rbp):
#        pc = long(pc)
#        # FIXME - there's no way to get this generally,
#        # so this is Emacs-specific.
#        context = gdb.lookup_global_symbol("emacs_jit_context").value()
#        if long(context) == 0:
#            return False
#        func = context['functions']
#        while long(func) != 0:
#            if pc >= long(func["entry_point"]) and pc < long(func["code_end"]):
#                add_function_range(long(rbp), long(func["entry_point"]),
#                                   long(func["code_end"]))
#                return True
#            func = func["next"]
#        return False
#
#    def __call__(self, pending_frame):
#        # Just x86-64 for now.
#        pc = pending_frame.read_register("rip")
#        rbp = pending_frame.read_register("rbp")
#        if not self.our_frame(pc, rbp):
#            return None
#
#        # Convenient type to work with.
#        ptr = gdb.lookup_type("void").pointer().pointer()
#
#        # Previous frame pointer is at 0(%rbp).
#        as_ptr = rbp.cast(ptr)
#        prev_rbp = as_ptr.dereference()
#        # Previous PC is at 8(%rbp)
#        prev_pc = (as_ptr + 1).dereference()
#
#        frame_id = FrameId(prev_rbp, prev_pc)
#        unwind_info = pending_frame.create_unwind_info(frame_id)
#        unwind_info.add_saved_register("rip", prev_pc)
#        unwind_info.add_saved_register("rbp", prev_rbp)
#
#        return unwind_info
#
#def register_unwinder(objf):
#    # Register the unwinder.
#    unwinder = LibjitUnwinder()
#    gdb.unwinder.register_unwinder(objf, unwinder, replace=True)
#    # Register the frame filter.
#    filt = LibjitFrameFilter()
#    if objf is None:
#        objf = gdb
#    objf.frame_filters[filt.name] = filt
