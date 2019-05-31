# The Drawing (set list to see line ending)
IFS='' read -r -d '' img1 <<"EOF"
                                                     
                                       /)            
              /\___/\         /\___/\ ((             
              `)9 9('         \`@_@'/  ))            
              {_:Y:.}_        {_:Y:.}_//             
    ----------( )U-'( )-------{_}^-'{_}--------------
              ```   '''                              
                                                     
EOF

# Get environment
lines=$(tput lines)
columns=$(tput cols)


# Declare function to center according to first line
print_centered(){
  first_line=$(echo -e "$1" | head -n 1)
  len=${#first_line}
  i_space=$(( ( $columns - $len ) / 2  ))
  while IFS= read -r line; do 
    printf "%${i_space}s%s\n" "" "$line"
  done< <(printf '%s\n' "$1")
}


# START
echo -e "\n\n"


# TITLE
title="El terminal de la Ponette"
printf "%*s\n" $(( ( ${#title} + $columns ) / 2  )) "$title"


# IMAGE
print_centered "$img1"


# PROVERB
print_centered "$(fortune)"


# END
echo -e "\n\n\n"
