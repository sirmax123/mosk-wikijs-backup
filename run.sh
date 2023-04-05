echo "# mosk-wikijs-backup" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M master
git remote add origin git@github.com:sirmax123/mosk-wikijs-backup.git
git push -u origin master
