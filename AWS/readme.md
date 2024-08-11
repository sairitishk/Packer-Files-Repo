- Make sure Packer is installed in the machine where we run the scripts 
(if local, path in Path env var; if remote, packer in /usr/local/bin)

- For Local:
Using profile mode to get creds and they are passed in .aws creds file under default profile.
When running packer in remote, comment this line and pass env vars.

- For remote:

(create an IAM user with admin or req. permissions, create access and secret key for that user and pass them here)

> Windows:

    $env:AWS_ACCESS_KEY_ID = ""
    $env:AWS_SECRET_ACCESS_KEY = ""


>    Linux:

    export AWS_ACCESS_KEY_ID=""
    export AWS_SECRET_ACCESS_KEY=""

- Better set them in .bashrc since env vars set will erase once instance is rebooted.
