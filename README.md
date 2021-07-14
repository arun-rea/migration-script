# migration-script
This is a simple migration script to clone all the repositories from source GitHub account to destination

## How to run
- Clone the repo into the server or local machine using the command `git clone git@github.com:arun-rea/migration-script.git`
- open the directory `cd migration-script`
- Add execution privilege to the script file `chmod +x git-migration.sh`
- Execute the command `./git-migration.sh <source user token> <maximum pages> <repository count in each page>`

## Things to note

- Inorder to execute this script, you need to create personal access tokens from the REA GHE and as well as PG GitHub
- GHE token (source) needs to be passed via the command line, where the PG Token (destination) is hardedcode in the script.
