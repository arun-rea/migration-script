#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Pass the Access Token <space> Number of Pages <space> Number of repositories per pages"
    exit 1
else
    token=$1
fi

if [ -z "$2" ]; then
    max=1
else
    max=$2
fi

if [ -z "$3" ]; then
    repos=2
else
    repos=$3
fi

# starting page number
page=1

# Personal token of destination Github [this may need to change later]
dest_token=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

until [ $max -lt $page ];do

    for i in $(curl "https://api.git.realestate.com.au/orgs/pg-rea-transition/repos?access_token=$token&page=$page&per_page=$repos" | grep '"ssh_url"' | cut -d '"' -f4 ); do
        echo git clone "$i"
        # make a "bare" clone of the external repository (full copy of the data, but without a working directory):
        git clone --bare "$i"
        basename=$(basename $i)

        #get the repo name
        filename=${basename%.*}
        # push the mirror to the new GitHub repository
        cd $basename
        # create new repository in destination github account.
        # curl -H "Authorization: token $dest_token" --data "{\"name\":\"$filename\",\"private\":\"true\"}" https://api.github.com/orgs/propertyguru/repos
        curl -H "Authorization: token $dest_token" --data "{\"name\":\"$filename\",\"private\":\"true\"}" https://api.github.com/user/repos
        #push the repository to destination account
        git push --mirror git@github.com:arun-rea/$basename

        # remove temporary local repo
        cd ..
        echo $(pwd)
        rm -rf $basename
    done
    let page++
done