#!/bin/sh
set -e

if [ -z "$1" ]; then
  command="server"
else
  command="$1"
fi

clean_deps() {
  rm -r $VENDOR_BUNDLE $M2_REPO
}

deps() {
  echo Retrieving dependencies.
  if [ -d Gemfile.lock ]; then
    ruby --dev -S bundle update --path $VENDOR_BUNDLE
  else
    ruby --dev -S bundle install --path $VENDOR_BUNDLE
  fi
  unset PACER_MANUAL_JARS
  ruby --dev -S bundle exec ruby --dev -I lib -e "puts 'Resolving jar dependencies'; require '${XN_CLIENT}'; puts 'Resolved jar dependencies'"
  export PACER_MANUAL_JARS=true
}

ensure_deps() {
  if [ ! -d "$M2_REPO" ] || \
     [ ! -d "$VENDOR_BUNDLE" ] ; then
    deps
  fi
}


if [ "$command" = 'server' ]; then
  set
  ensure_deps
  export JAVA_OPTS="-server $JAVA_OPTS"
  exec bundle exec puma -b tcp://0.0.0.0:8080 -e $XN_ENV
elif [ "$command" = 'console' ]; then
  ensure_deps
  export JRUBY_OPTS="--dev $JRUBY_OPTS"
  exec bundle exec irb -r $XN_CLIENT
elif [ "$command" = 'rspec' ]; then
  ensure_deps
  export JRUBY_OPTS="--dev $JRUBY_OPTS"
  exec bundle exec rspec
elif [ "$command" = 'deps' ]; then
  deps
  exec echo Done.
fi

exec "$@"
