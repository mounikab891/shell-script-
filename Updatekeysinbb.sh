repolist=$(curl -u $Username:$Token "https://api.bitbucket.org/2.0/repositories?role=member&pagelen=1000" | jq -r '.values[].name'| sed 's/ /-/g')
echo $repolist
for repo_name in $repolist; do
  git clone "https://$Username:$Token@bitbucket.org/Workspace/$repo_name.git"

echo "$repo_name"
  filtered_branches=""
  cd $repo_name
  bitbucket_username="XXXXX"
  bitbucket_password="XXXXX"
  access_keys=("XXXX" "XXX")
  secret_keys=("XXXX" "XXXX")

  branches=$(git branch -r |  sed 's/origin\///' | grep -v master | grep -v staging | grep -v release | grep -v HEAD)
  echo $branches------fghjk
  for branch in $branches; do
     git checkout "$branch"
    modified=0
    IFS=$'\n'
    files=$(find /home/$repo_name -type f | grep -v .git)
    for file in $files; do
      IFS=$'\n'
      
      for access_key in "${access_keys[@]}"; do
	   if grep  "$access_key" "$file"; then
        #if cat "$file" | grep "$access_key" ; then
          echo "----------------------------------------------"
          echo "Please wait!!! replacing access_key at $file"
          echo "----------------------------------------------"
          sed -i "s|$access_key|<New-Access-Key>|g" "$file"
          modified=1
          echo "$branch $file" >> /tmp/modify
        fi
      done

      IFS=$'\n'
      for secret_key in "${secret_keys[@]}"; do
        #if cat "$file" | grep "$secret_key" ; then
        if grep "$secret_key" "$file"; then
          echo "----------------------------------------------"
          echo "Please wait!!! replacing secret_key at $file"
          echo "----------------------------------------------"
          sed -i "s|$secret_key|<New-Secret-Key>|g" "$file"
          modified=1
          echo "$branch $file" >> /tmp/modify
        fi
      done
      done
    git add .
    git commit -m "XXXXX"
    git push origin "$branch"
  done
  cd ..
  rm -rf $repo_name

done
echo "----------------------------------------------"
echo "modified files"
echo "----------------------------------------------"
sort -u /tmp/modify >/tmp/origin
