set history save on
#set  disassemble-next-line on
#show disassemble-next-line

define rip
  # Show current instruction
  x/15i $pc
end

define p
  rip
end

define rdi
  x/20xa $rdi
end

define r12
  x/20xa $r12
end

define rbp
  x/20xa $rbp
end

define rax
  x/20xa $rax
end

define rsp
  x/20xa $rsp
end

define stack
  x/20xa $rsp
end

define ret
  # fin
  finish
end

define rush
  # Ignore SIGTRAP
  # From: https://stackoverflow.com/questions/15667795
  catch signal SIGTRAP
  commands
    silent
    set $pc++
    p $_siginfo.si_code
    c
  end
  c
end

define rushend
  # info breakpoint
  delete
end


define s
  # Step one instruction, enter in function
  stepi
  rip
end

define n
  # Next instruction, call is 1 instruction
  nexti
  rip
end

define reg
  # Show registers
  info reg
end
