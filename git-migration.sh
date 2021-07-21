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
    curl -X DELETE \
         -H "Authorization: token $token" \
         -H "Accept: application/vnd.github.v3+json" \
         https://api.github.com/repos/propertyguru/"$repo_name" \
         || true
}

until [ $max -lt $page ];do

    for i in $(curl "https://api.git.realestate.com.au/orgs/pg-rea-transition/repos?access_token=$token&page=$page&per_page=$repos" | grep '"ssh_url"' | cut -d '"' -f4 ); do
        echo git clone "$i"
        # make a "bare" clone of the external repository (full copy of the data, but without a working directory):
        git clone --bare "$i"
        basename=$(basename $i)

        #get the repo name
        filename=${basename%.*}

        # push the mirror to the new GitHub repository
        cd "$basename" || exit

        # delete repo if already present in the destination github account
        delete_repo "$dest_token" "$filename"

        # create new repository in destination github account based on organisation
        curl -H "Authorization: token $dest_token" \
             --data "{\"name\":\"$filename\",\"private\":\"true\"}" \
             https://api.github.com/orgs/propertyguru/repos
        curl -X PUT \
             -H "Accept: application/vnd.github.v3+json" \
             -H "Authorization: token $dest_token" \
             --data "{\"org\":\"propertyguru\",\"team_slug\":\"iproperty\",\"repo\":\"$filename\",\"permission\":\"maintain\",\"owner\":\"propertyguru\"}" \
             https://api.github.com/orgs/propertyguru/teams/iproperty/repos/propertyguru/"$filename"
        
        # create new repository in destination github account based on user
        # curl -H "Authorization: token $dest_token" \
        #    --data "{\"name\":\"$filename\",\"private\":\"true\"}" \
        #    https://api.github.com/user/repos
            
        #push the repository to destination account
        git push --mirror git@github.com:propertyguru/"$basename"

        # remove temporary local repo
        cd ..
        rm -rf "$basename"
    done
    let page++
done


