_default:
  @ just --list --unsorted 
  @ echo ""
  @ cd backend && just --list --unsorted --list-heading '' --list-prefix '    backend/'
  @ echo ""
  @ cd elm-shared && just --list --unsorted --list-heading '' --list-prefix '    elm-shared/'
  @ echo ""
  @ cd webapp && just --list --unsorted --list-heading '' --list-prefix '    webapp/'
  @ echo ""
  @ cd admin && just --list --unsorted --list-heading '' --list-prefix '    admin/'
  @ echo ""
  @ cd uikit && just --list --unsorted --list-heading '' --list-prefix '    uikit/'
  @ echo ""
  @ cd terraform && just --list --unsorted --list-heading '' --list-prefix '    terraform/'

sync:
  #!/bin/sh
  set -eu
  just backend/schema
  cd elm-shared
  npm run codegen
  echo "\n\n✅ Sync completed!\n\n"

precommit-fix:
  #!/bin/sh
  set -eu
  just sync
  just backend/precommit-fix
  just elm-shared/precommit-fix
  just webapp/precommit-fix
  just admin/precommit-fix
  just uikit/precommit-fix
  echo "\n\n✅ Precommit-fix completed!\n\n"

check-and-build:
  #!/bin/sh
  set -eu
  just sync
  just backend/check-and-build
  just elm-shared/check-and-build
  just webapp/check-and-build
  just admin/check-and-build
  just uikit/check-and-build
  echo "\n\n✅ Check and Build completed!\n\n"

reinstall-frontend-deps:
  #!/bin/sh
  set -eu
  cd elm-shared && rm -rf node_modules && rm -f package-lock.json && npm install && cd ..
  cd webapp && rm -rf node_modules && rm -f package-lock.json && npm install && cd ..
  cd admin && rm -rf node_modules && rm -f package-lock.json && npm install && cd ..
  cd uikit && rm -rf node_modules && rm -f package-lock.json && npm install && cd ..
  echo "\n\n✅ Reinstalled!\n\n"


