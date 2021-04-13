set history save on
#set  disassemble-next-line on
#show disassemble-next-line

define rip
  # Show current instruction
  x/15i $pc
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

define ret
  # fin
  finish
end

define rush
  # Ignore SIGTRAP
  catch signal SIGTRAP
    commands
    p $_siginfo.si_code
    c
  end
  c
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

define stack
  # Show stack 
  x/20xa $rsp
end

define reg
  # Show registers
  info reg
end
