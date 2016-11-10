#!/usr/bin/env bash

httpd_config=$(httpd -V | grep -i SERVER_CONFIG_FILE | awk -F '"' '{print $2}')
vhosts_dir=${httpd_config%/*}/vhosts
vhost_config=${vhosts_dir}/test-dot-dev-and-local.conf
listen_port=$(grep '^Listen' "$httpd_config" | awk '{print $2}')

# make sure httpd is including vhost-configs
# a. try and reuse default commented out vhost-decleration
sed -i .orig "s|#Include\(.*vhosts.*\)$|Include ${vhosts_dir}/*conf|" "$httpd_config"

# b. simply append our own
if ! grep "Include ${vhosts_dir}/\*conf" "$httpd_config"; then
   echo "Include ${vhosts_dir}/*conf" >> "$httpd_config"
fi

mkdir -p "$vhosts_dir"

# replace {{…}} placeholders and write our vhost-config
sed "s|{{PATH}}|$(PWD)|g" vhosts-template.conf \
   | sed "s|{{PORT}}|${listen_port}|g" \
   > "$vhost_config"

# bail if something looks wrong
if ! apachectl configtest; then
   exit 1
fi

# Optionally: [Clear the local DNS cache in macOS Sierra](https://coolestguidesontheplanet.com/clear-the-local-dns-cache-in-osx/)
# sudo killall -HUP mDNSResponder

apachectl -k restart &> /dev/null

# configure test run

result_id=$(date +%s)
result_file=results/${result_id}.md
mkdir -p results

hostnames=$(grep ServerName vhosts-template.conf | awk '{print $2}')

# helper functions

logresult() {
   if [[ -f $1 ]]; then
      echo "**${1}**" >> "$result_file"
      echo            >> "$result_file"
      echo '```'      >> "$result_file"
      cat "$1"        >> "$result_file"
      echo '```'      >> "$result_file"
      echo            >> "$result_file"
   else
      echo "$1" >> "$result_file"
   fi
}

test_hostname() {
   logresult "### ${1} response"
   logresult
   logresult '```'
   curl -w '@curl-template.txt' --connect-timeout 10 -s http://${1}:$listen_port >> "$result_file"
   logresult '```'
   logresult
}

# do test

logresult "# run $result_id"
logresult
logresult '**System**'
logresult
logresult '```'
logresult "$(sw_vers)"
logresult "$(httpd -v)"
logresult '```'
logresult

for name in $hostnames; do
   if ! grep "$name" /etc/hosts &> /dev/null; then
      echo "127.0.0.1 $name" | sudo tee -a /etc/hosts > /dev/null
   fi

   test_hostname $name
done

logresult '## Configs'
logresult
logresult /etc/hosts
logresult "$vhost_config"

open "$result_file"
