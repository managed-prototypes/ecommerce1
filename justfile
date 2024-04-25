_default:
  @ just --list --unsorted 
  @ echo ""
  @ cd backend && just --list --unsorted --list-heading '' --list-prefix '    backend/'
  @ echo ""
  @ cd terraform && just --list --unsorted --list-heading '' --list-prefix '    terraform/'

sync:
  #!/bin/sh
  set -eu
  just backend/schema
  cd elm-shared
  npm run codegen
