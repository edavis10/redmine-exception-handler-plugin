#/bin/bash
set -e # exit if any command fails

setenv() {
  export RAILS_ENV=test
  export PATH_TO_PLUGIN=$(pwd)
  export RUBY_VERSION=$(ruby -e 'print RUBY_VERSION')
  if [[ -z "$REDMINE" ]]; then
    echo "You have not set REDMINE"
    exit 1
  fi
  if [ "$VERBOSE" = "yes" ]; then export TRACE=--trace; fi
  if [ ! "$VERBOSE" = "yes" ]; then export QUIET=--quiet; fi

  case $REDMINE in
    2.*.*)  export PATH_TO_PLUGINS=./plugins # for redmine 2.x.x
            export GENERATE_SECRET=generate_secret_token
            export MIGRATE_PLUGINS=redmine:plugins
            export REDMINE_TARBALL=https://github.com/edavis10/redmine/archive/$REDMINE.tar.gz
            ;;
    2.*-stable) export PATH_TO_PLUGINS=./plugins # for redmine 2.x-stable
            export GENERATE_SECRET=generate_secret_token
            export MIGRATE_PLUGINS=redmine:plugins
            export REDMINE_SVN_REPO=http://svn.redmine.org/redmine/branches/$REDMINE
            ;;
    master) export PATH_TO_PLUGINS=./plugins
            export GENERATE_SECRET=generate_secret_token
            export MIGRATE_PLUGINS=redmine:plugins
            export REDMINE_SVN_REPO=http://svn.redmine.org/redmine/trunk/
            ;;
    v3.8.0) export PATH_TO_PLUGINS=./vendor/chiliproject_plugins
            export GENERATE_SECRET=generate_session_store
            export MIGRATE_PLUGINS=db:migrate:plugins
            export REDMINE_TARBALL=https://github.com/chiliproject/chiliproject/archive/$REDMINE.tar.gz
            export RUBYGEMS=1.8.29
            ;;
    *)      echo "Unsupported platform $REDMINE"
            exit 1
            ;;
  esac
}

extract_args() {
  while :; do
    case "$1" in
      --target) export TARGET="$2"; shift; shift;;
      -*) echo "Invalid argument $1"; exit 2;;
      *) break;;
    esac
  done
}

trace() {
  if [ "$VERBOSE" = "yes" ]; then echo $@; fi
}

clone_redmine()
{
  setenv; extract_args $@

  if [[ -z "$TARGET" ]]; then
    echo "You have not set a target directory"; exit 1
  fi

  rm -rf $TARGET
  if [ -n "${REDMINE_GIT_REPO}" ]; then
    git clone -b $REDMINE_GIT_TAG --depth=100 $QUIET $REDMINE_GIT_REPO $TARGET
    pushd $TARGET 1> /dev/null
    git checkout $REDMINE_GIT_TAG
    popd 1> /dev/null
  elif [ -n "${REDMINE_HG_REPO}" ]; then
    hg clone -r $REDMINE_HG_TAG $QUIET $REDMINE_HG_REPO $TARGET
  elif [ -n "${REDMINE_SVN_REPO}" ]; then
    svn co $QUIET $REDMINE_SVN_REPO $TARGET
  else
    mkdir -p $TARGET
    wget $REDMINE_TARBALL -O- | tar -C $TARGET -xz --strip=1 --show-transformed -f -
  fi

  # Temporarily pin down database_cleaner for bug with sqlite, see https://github.com/bmabey/database_cleaner/issues/224
  sed -ri 's/gem "database_cleaner"/gem "database_cleaner", "< 1.1.0"/' $TARGET/Gemfile
}

install_plugin_gemfile()
{
  setenv

  mkdir $REDMINE_DIR/$PATH_TO_PLUGINS/$PLUGIN_NAME
  rm -f "$REDMINE_DIR/$PATH_TO_PLUGINS/$PLUGIN_NAME/Gemfile"
  ln -s "$PATH_TO_PLUGIN/config/Gemfile.travis" "$REDMINE_DIR/$PATH_TO_PLUGINS/$PLUGIN_NAME/Gemfile"
}

bundle_install()
{
  setenv

  if [ -n "${RUBYGEMS}" ]; then
    rvm rubygems ${RUBYGEMS}
  fi
  pushd $REDMINE_DIR 1> /dev/null
  for i in {1..3}; do
    gem install bundler $QUIET --no-rdoc --no-ri && \
    bundle install $QUIET --gemfile=./Gemfile --path vendor/bundle --without development rmagick && break
  done && popd 1> /dev/null
}

prepare_redmine()
{
  setenv

  pushd $REDMINE_DIR 1> /dev/null

  trace 'Database migrations'
  bundle exec rake db:migrate $TRACE

  trace 'Load defaults'
  bundle exec rake redmine:load_default_data REDMINE_LANG=en $TRACE

  trace 'Session token'
  bundle exec rake $GENERATE_SECRET $TRACE

  popd 1> /dev/null
}

prepare_plugin()
{
  setenv

  pushd $REDMINE_DIR 1> /dev/null

  ln -s $PATH_TO_PLUGIN/* $PATH_TO_PLUGINS/$PLUGIN_NAME

  trace 'Prepare plugins'
  bundle exec rake $MIGRATE_PLUGINS NAME=$PLUGIN_NAME $TRACE

  popd 1> /dev/null
}

run_tests()
{
  setenv

  pushd $REDMINE_DIR 1> /dev/null

  if [ "$REDMINE" == "master" ] && [ "$RUBY_VERSION"  == "1.9.3" ]; then
    bundle exec rake redmine:plugins:exception_handler:coveralls:test $TRACE
  else
    bundle exec rake redmine:plugins:exception_handler:test $TRACE
  fi

  popd 1> /dev/null
}

test_uninstall()
{
  setenv

  pushd $REDMINE_DIR 1> /dev/null

  bundle exec rake $TRACE $MIGRATE_PLUGINS NAME=$PLUGIN_NAME VERSION=0

  popd 1> /dev/null
}

case "$1" in
  "clone_redmine") shift; clone_redmine $@;;
  "install_plugin_gemfile") shift; install_plugin_gemfile $@;;
  "bundle_install") shift; bundle_install $@;;
  "prepare_redmine") shift; prepare_redmine $@;;
  "prepare_plugin") shift; prepare_plugin $@;;
  "start_ldap") shift; start_ldap $@;;
  "run_tests") shift; run_tests $@;;
  "test_uninstall") shift; test_uninstall $@;;
  *) echo "clone_redmine; install_plugin_gemfile; prepare_redmine; prepare_plugin; start_ldap; run_tests; test_uninstall";;
esac
