echo "use it like ./gitscript.sh \"my commited string\""
git init 
git add .
#git remote add origin https://github.com/tinmarino/Vimfiles.git
if [[ $1 == "" ]] 
then 
   echo "no first arg, taking auto commit " 
   git commit -m "auto commit"
else 
   git commit -m "$1"
fi 
git push -u origin master 


# if some bundles does not appear in github, just 
# try removing the .git and .gitignore in these bundles
# git rm --cached bundles/vim-misc
# git add bundles/vim-misc[/*]    # with or without the /* work

