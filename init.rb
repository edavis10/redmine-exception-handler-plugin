require 'redmine'

Dir[File.join(Redmine::Plugin.directory,'redmine_exception_handler','vendor','plugins','*')].each do |dir|
  path = File.join(dir, 'lib')
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
#  Rails::Engine::Configuration.autoload_once_paths.delete(path)
end

Redmine::Plugin.register :redmine_exception_handler do
  name 'Redmine Exception Handler plugin'
  author 'Eric Davis'
  description 'Send emails when exceptions occur in Redmine.'
  version '0.2.0'
  requires_redmine :version_or_higher => '2.0.0'
  
  settings :default => {
    'exception_handler_recipients' => 'you@example.com, another@example.com',
    'exception_handler_sender_address' => 'Application Error <redmine@example.com>',
    'exception_handler_prefix' => '[ERROR]',
    'exception_handler_email_format' => 'text'
  }, :partial => 'settings/exception_handler_settings'
  
end


require_dependency 'exception_notification'
ExceptionNotifier::Notifier.send(:include, ExceptionHandler::RedmineNotifierPatch)

settings = Setting.plugin_redmine_exception_handler
RedmineApp::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => settings['exception_handler_prefix'],
  :sender_address => settings['exception_handler_sender_address'],
  :exception_recipients => settings['exception_handler_recipients'].split(',').map(&:strip),
  :email_format => (settings['exception_handler_email_format'] || 'text').to_sym

RedmineApp::Application.config.after_initialize do; end