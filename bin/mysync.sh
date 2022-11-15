
function work {
  echo -e "echo -e \"\n\n---------\nSync: $1\""
	echo rsync -avr \
        --exclude=Old --exclude=SDK --exclude=Sdk --exclude=build --exclude=Jar --exclude=EmSdk \
        ~/"$1"/  /media/tourneboeuf/10a73a70-992f-4d07-adc6-30b2a8086850/Alma/"$1"
}

list=(
Images/Foto
Papier
Documents
Software
wiki
Repo
Litterature
# ".vim"
# "Res"
# "Game"
)

for i in "${list[@]}"
do
	work "$i"
done
