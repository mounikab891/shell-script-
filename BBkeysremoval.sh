#!/bin/bash

repo_name="askadocBackend"

  filtered_branches=""
  cd $repo_name
  bitbucket_username=""
  bitbucket_password=""
  access_keys=("")
  secret_keys=("")

  branches=$(git branch -r | awk -F'origin/' '!/\/Prefix1\/|\/prefix2\//' | grep -v master | grep -v staging | grep -v HEAD)
  #echo $branches
  for k in $branches; do
    branch=$(echo "$k" | sed 's/origin\///')
    if [ "$(git log --before="1 month ago")" ]; then
      #echo "$branch"
      filtered_branches+=" $branch"
     #echo $filtered_branches
    fi
  done

  for filteredbranch in $filtered_branches; do
    echo "$filteredbranch"
    git stash
    git checkout "$filteredbranch"
    modified=0
    IFS=$'\n'
    files=$(find /home/$repo_name -type f | grep -v .git)
    for file in $files; do
      IFS=$'\n'
      for access_key in "${access_keys[@]}"; do
        if cat "$file" | grep "$access_key" ; then
          echo "----------------------------------------------"
          echo "Please wait!!! replacing access_key at $file"
          echo "----------------------------------------------"
          sed -i "s/$access_key/<New-Access-Key>/g" "$file"
          modified=1
          echo "$filteredbranch $file" >> /home/modify
        fi
      done

      IFS=$'\n'
      for secret_key in "${secret_keys[@]}"; do
        if cat "$file" | grep "$secret_key" ; then
          echo "----------------------------------------------"
          echo "Please wait!!! replacing secret_key at $file"
          echo "----------------------------------------------"
          sed -i "s/$secret_key/<New-Secret-Key>/g" "$file"
          modified=1
          echo "$filteredbranch $file" >> /home/modify
        fi
      done
    done
    #done
    git add .
    git commit -m "IM-1273"
    git push origin "$filteredbranch"
  done
  cd ..
  rm -rf $repo_name


echo "----------------------------------------------"
echo "modified files"
echo "----------------------------------------------"
sort -u /home/modify >/tmp/origin


