
Clear-Host

# 1. Wipe the entire index, ignoring missing file errors
git rm -r --cached --ignore-unmatch .

# 2. Guarantee the .gitignore is strictly readable by the Git engine
(Get-Content .gitignore) | Set-Content .gitignore -Encoding utf8

# 3. Rebuild the staging area (this will now successfully skip .vs and videos)
git add .

# 4. Overwrite the bloated commit
git commit --amend -m "Initial commit, strict index rebuild"

# 5. Push the lightweight payload
git push -u origin HEAD
