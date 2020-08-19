# From: https://github.com/junegunn/fzf/issues/1928
# From: https://gist.github.com/junegunn/f4fca918e937e6bf5bad#gistcomment-2981199

#if [[ -e ${input} && $(file --mime ${input}) =~ /directory ]]; then
#  ls -1 --color=always ${input}
#elif [[ -e ${input} && $(file --mime ${input}) =~ binary ]]; then
#  echo -ne "" # I don't want to show the preview window
#elif [[ ${input} =~ .*:[[:digit:]]*:.* ]]; then
#  # etc
#fi

input="$*"
set -- "$(echo -- "$input" | grep -o '[a-f0-9]\{7\}')";
if [ $# -eq 0 ]; then
    # missing some potential argument of git log (filter)
    git show --color=always "$input"
else
    bat --style=numbers --color=always --line-range :500 "$input"
fi
