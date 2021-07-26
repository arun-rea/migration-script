# REA GitHub Migration Script
This is a simple migration script to export all the repositories from source GitHub account to destination GH account

## How to run
- Clone the repo into the server or local machine using the command `git clone git@github.com:arun-rea/migration-script.git`
- open the directory `cd migration-script`
- Add execution privilege to the script file `chmod +x git-migration.sh`
- Set environment variables `USER_NAME`, `SOURCE_TOKEN` & `DEST_TOKEN` with the personal user token generated from GHE and PG's GitHub accounts
- Execute the command `./git-migration.sh <maximum pages> <repository count in each page>`
    - Default Value for both `<maximum pages>` & `<repository count in each page>` are `1` each. 
    - Running `./git-migration.sh` w/o passing params will just export one repo from the first page if the GH Organisation.
    - For exporting all the repositories, you can run `./git-migration.sh 10 100` which will make sure all the repos get migrated.

## Things to note

- Inorder to execute this script, you need to create personal access tokens from the REA GHE and as well as PG GitHub
- You can set the env variables with below commands
    - `export SOURCE_TOKEN=<GHE token>`
    - `export DEST_TOKEN=<PG Token>`
- You can set your GHE user name as `export USER_NAME=<GHE username>` . Note the user name is not the email address and shouldn't have the domain name with it.

## Running in Linux Server
- You can use this command to run the script as a background process - `nohup ./git-migration.sh <maximum pages> <repository count in each page> &> migration_logfile.log`
- Inorder to see the status of the migration of the repos, you can use - `tail -f migration_logfile.log | grep "Migrated Repository"`