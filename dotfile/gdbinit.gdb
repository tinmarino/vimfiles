set history save on

define s
stepi
x/15i $pc
end

define n
nexti
x/15i $pc
end

define stack
x/20xa $rsp
end

define reg
info reg
end
