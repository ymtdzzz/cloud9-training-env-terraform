#!/bin/bash

terraform output -json | ruby -rjson -ryaml -e 'json = JSON.load(ARGF); keys = %w(user encrypted_password); puts [keys, *keys.map{|key| v = json[key]["value"].split; key == "encrypted_password" ? v.map{|s| `echo #{s} | base64 -d | keybase pgp decrypt -S ymatsuda`.chomp} : v}.transpose].map{|a| a.join(",")}'
