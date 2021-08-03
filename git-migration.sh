#!/bin/bash

# Personal token of source Github 
if [[ -z "${SOURCE_TOKEN}" ]]; then
    echo "Error: Please set the environment variable SOURCE_TOKEN"
    exit 1
else
  token="${SOURCE_TOKEN}"
fi

# Personal token of destination Github 
if [[ -z "${DEST_TOKEN}" ]]; then
    echo "Error: Please set the environment variable DEST_TOKEN"
    exit 1
else
  dest_token="${DEST_TOKEN}"
fi

# User Name of the source Gituhb
if [[ -z "${USER_NAME}" ]]; then
    echo "Error: Please set the environment variable USER_NAME"
    exit 1
else
  user_name="${USER_NAME}"
fi

if [ -z "$1" ]; then
    max=1
else
    max=$1
fi

if [ -z "$2" ]; then
    repos=1
else
    repos=$2
fi

# starting page counter
page=1
counter=1

# helper function to clean up if any existing docker containers and images
function delete_repo(){
    if [ -z "$1" ]; then
        echo "Pass authorization token"
        exit 1
    else
        token=$1
    fi

    if [ -z "$2" ]; then
        echo "Pass the repository name to delete"
        exit 1
    else
        repo_name=$2
    fi
    # delete repository
    curl --fail --silent --show-error -X DELETE \
         -H "Authorization: token $token" \
         -H "Accept: application/vnd.github.v3+json" \
         https://api.github.com/repos/propertyguru/"$repo_name" \
         > /dev/null \
         || true
}

while [ $page -le $max ]; do
    for i in $(curl "https://api.git.realestate.com.au/orgs/pg-rea-transition/repos?access_token=${SOURCE_TOKEN}&page=$page&per_page=$repos" | grep '"clone_url"' | cut -d '"' -f4 | sed 's~http[s]*://~~g'); do
        echo git clone "$i"
        # setting the datetime
        CURRENT_DATE=`date +"%Y-%m-%d %T"`

        # make a "bare" clone of the external repository (full copy of the data, but without a working directory):
        git clone --bare "https://${USER_NAME}:${SOURCE_TOKEN}@$i"
        basename=$(basename $i)

        #get the repo name
        filename=${basename%.*}

        # push the mirror to the new GitHub repository
        cd "$basename" || exit

        # delete repo if already present in the destination github account
        delete_repo "$dest_token" "$filename"

        # create new repository in destination github account based on organisation
        curl --fail --silent --show-error -H "Authorization: token $dest_token" \
             --data "{\"name\":\"$filename\",\"private\":\"true\"}" \
             https://api.github.com/orgs/propertyguru/repos > /dev/null
        curl --fail --silent --show-error -X PUT \
             -H "Accept: application/vnd.github.v3+json" \
             -H "Authorization: token $dest_token" \
             --data "{\"org\":\"propertyguru\",\"team_slug\":\"iproperty\",\"repo\":\"$filename\",\"permission\":\"maintain\",\"owner\":\"propertyguru\"}" \
             https://api.github.com/orgs/propertyguru/teams/iproperty/repos/propertyguru/"$filename" > /dev/null 
        
        # create new repository in destination github account based on user
        # curl -H "Authorization: token $dest_token" \
        #    --data "{\"name\":\"$filename\",\"private\":\"true\"}" \
        #    https://api.github.com/user/repos
            
        #push the repository to destination account
        if git push --mirror git@github.com:propertyguru/"$basename"
        then
            echo "${CURRENT_DATE} ******* Migrated Repository - $i ; Repositories completed: $counter *******"
        else
            echo "${CURRENT_DATE} Repository - $i failed to push"
        fi

        # remove temporary local repo
        cd ..
        rm -rf "$basename"

        let counter++
    done
    page=$(( page+1 ))
done


