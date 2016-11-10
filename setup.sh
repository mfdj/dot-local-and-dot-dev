#!/usr/bin/env bash

command -v brew > /dev/null || {
   echo 'Install Homebrew first: http://brew.sh'
   exit 1
}

brew install homebrew/apache/httpd24
