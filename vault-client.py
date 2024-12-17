#!/usr/bin/python3

"""requires git-credential-keepassxc to be in PATH
https://github.com/Frederick888/git-credential-keepassxc/

e.g. download https://github.com/Frederick888/git-credential-keepassxc/releases/download/v0.14.0/ubuntu-latest-full.zip
and extract to /usr/local/bin

then configure:
git-credential-keepassxc caller add --uid "$(id -u)" --gid "$(id -g)" "/usr/bin/python3.10"  # insert your python interpreter binary here
git-credential-keepassxc configure --group ansible

add your password to group "ansible" and use as "url":
http://<vaultname>.local

following command should print the name of this script as debug-output
ansible-vault encrypt_string -vvvv --stdin-name 'ansible_sudo_pass' --encrypt-vault-id kurzlink
"""

import argparse
import json
import subprocess
import sys
import os


def build_arg_parser():
    parser = argparse.ArgumentParser(description="Get a vault password from KeePassXC")

    parser.add_argument(
        "--vault-id",
        action="store",
        dest="vault_id",
        help="name of the vault secret",
    )
    return parser


def main():
    arg_parser = build_arg_parser()
    args = arg_parser.parse_args()
    vault_id = args.vault_id
    vault_pw_file = f".passwords/{ vault_id }"
    try:
        # file exsits and is readable
        if os.path.isfile(vault_pw_file) and os.access(vault_pw_file, os.R_OK):
            with open(vault_pw_file) as f:
                password = f.read()
        else:
            # query vault password from keepassxc
            content = f"url=http://{ vault_id }.local".encode("utf-8")
            result = subprocess.run(
                ["git-credential-keepassxc", "get", "--json"],
                input=content,
                stdout=subprocess.PIPE,
                check=False,
            )
            output = result.stdout.decode("utf-8")
            data = json.loads(output)
            password = data["password"]
    except Exception as e:
        # print error-message to stderr to not be counted as a password
        print(f"Error retrieving the vault-secret for { vault_id }\n{e}", file=sys.stderr)
        # fail properly to terminate ansible
        sys.exit(os.EX_IOERR)
    print(f"{ password }")
    sys.exit(os.EX_OK)


if __name__ == "__main__":
    main()
