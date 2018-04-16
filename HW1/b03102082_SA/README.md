# HW1 System Administration 
* The following are the usages of `deploy.sh`, `lottery.sh` and `jobs.sh`
  * `deploy.sh`
    * This is a script to run some commands on every CSIE workstation.
    * Usage: 
    ```
    ./deploy.sh [username] [private key] [command] 
    ```
    ```
    ./deploy.sh [username] [command]
    ```
    * The 1th command logins with `ssh key`, while the 2nd one logins with `password`
    * if you want to login with `ssh key`, please make sure that you have already `ssh-copy-id` the corresponding public key to all workstations
  * `lottery.sh`
    * This is a script to match the winning numbers of Taiwanese receipt lottery
    * Usage:
    ```
    ./lottery.sh [the file of winning numbers] [the file of receipt numbers]
    ```
  * `jobs.sh`
    * This is a script to reveal the resource usage of current system of different `process groups`
    * Usage: execute
    ```
    ./jobs.sh -h
    ```
    to see the help message
