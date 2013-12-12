Redmine Exception Handler [![Build Status](https://travis-ci.org/thorin/redmine_exception_handler.png?branch=master)](https://travis-ci.org/thorin/redmine_exception_handler?branch=master) [![Coverage Status](https://coveralls.io/repos/thorin/redmine_exception_handler/badge.png?branch=master)](https://coveralls.io/r/thorin/redmine_exception_handler?branch=master)
=========================

The Redmine Exception Handler plugin will allow Redmine to send emails when an exception or error occurs.

Features
--------

* Allows configuration of recipients, sender address, and subject line without restarting the web server
* Email contains a stack trace and full environment dump that can be used to reproduce the issue
* Test controller to test the system settings

Install
-------

1. Follow the Redmine plugin installation steps at: [http://www.redmine.org/wiki/redmine/Plugins](http://www.redmine.org/wiki/redmine/Plugins)
   Make sure the plugin is installed to `plugins/redmine_exception_handler`
2. Run bundle install
3. Login to Redmine as an Administrator
4. Setup your mail settings in the Plugin settings panel
5. Test your settings using the "Test settings" link

License
-------

This plugin is licensed under the GNU GPL v2.
See COPYRIGHT and COPYING for details.

Help
----

If you need help you can contact the maintainer at his email address (See CREDITS) or create an issue in the [Bug Tracker](https://projects.littlestreamsoftware.com/projects/show/redmine-exception)
