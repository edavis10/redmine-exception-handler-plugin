require 'redmine'

Dir[File.join(directory,'vendor','plugins','*')].each do |dir|
  path = File.join(dir, 'lib')
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

Redmine::Plugin.register :redmine_exception_handler_plugin do
  name 'Redmine Exception Handler plugin'
  author 'Eric Davis'
  description 'Send emails when exceptions occur in Redmine.'
  version '0.2.0'
  
  settings :default => {
    'exception_handler_recipients' => 'you@example.com, another@example.com',
    'exception_handler_sender_address' => 'Application Error <redmine@example.com>',
    'exception_handler_prefix' => '[ERROR]'
  }, :partial => 'settings/exception_handler_settings'
  
end

require_dependency 'exception_notifier'

module RedmineExceptionNotifierPatch
  def self.included(target)
    target.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def exception_notification_with_database(exception, controller, request, data={}, &block)
      if Object.const_defined?('Setting')
        ExceptionNotifier.exception_recipients = Setting.plugin_redmine_exception_handler_plugin['exception_handler_recipients'].split(',').map { |name| name.strip }
        ExceptionNotifier.sender_address = Setting.plugin_redmine_exception_handler_plugin['exception_handler_sender_address']
        ExceptionNotifier.email_prefix = Setting.plugin_redmine_exception_handler_plugin['exception_handler_prefix']
      end
      exception_notification_without_database(exception, controller, request, data, &block)
    end

  end
  
end
ExceptionNotifier.send(:include, RedmineExceptionNotifierPatch)
ExceptionNotifier.send(:alias_method_chain, :exception_notification, :database)
ActionController::Base.send(:include, ExceptionNotifiable)
