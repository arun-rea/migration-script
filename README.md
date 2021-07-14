# migration-script
This is a simple migration script to clone all the repositories from source GitHub account to destination

## How to run
- Clone the repo into the server or local machine using the command `git clone git@github.com:arun-rea/migration-script.git`
- open the directory `cd migration-script`
- Add execution privilege to the script file `chmod +x git-migration.sh`
- Set environment variables `SOURCE_TOKEN` & `DEST_TOKEN` with the personal user token generated from GHE and PG's GitHub accounts
- Execute the command `./git-migration.sh <maximum pages> <repository count in each page>`

## Things to note

- Inorder to execute this script, you need to create personal access tokens from the REA GHE and as well as PG GitHub
- You can set the env variables with below commands
    - `export SOURCE_TOKEN=<GHE token>`
    - `export DEST_TOKEN=<PG Token>`
