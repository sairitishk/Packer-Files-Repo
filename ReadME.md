To Run Packer,

1)  Make sure packer is installed in the machine and the pah is added to env vars (if remote in linux, packer should be in /usr/local/bin)

2) Run the commands:
    > packer fmt
    > packer validate -var-file <if any .pkvars file, pass it here> <name of template file>
    > packer inspect -var-file <if any .pkvars file, pass it here> <name of template file>
    > packer build -var-file <if any .pkvars file, pass it here> <name of template file>

3) Make sure env vars are set properly before executing.

Note: azure files are not working. detailed error msg inside. Will work later.