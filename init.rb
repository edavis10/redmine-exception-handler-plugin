require 'redmine'

Dir[File.join(directory,'vendor','plugins','*')].each do |dir|
  path = File.join(dir, 'lib')
  $LOAD_PATH << path
  Dependencies.load_paths << path
  Dependencies.load_once_paths.delete(path)
end

Redmine::Plugin.register :redmine_exception_handler do
  name 'Redmine Exception Handler plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  
  settings :default => {
    'exception_handler_recipients' => 'you@example.com',
    'exception_handler_sender_address' => 'Application Error <redmine@example.com>',
    'exception_handler_prefix' => '[ERROR]'
  }, :partial => 'settings/settings'
  
end

require_dependency 'exception_notifier'

module RedmineExceptionNotifierPatch
  def self.included(target)
    target.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def exception_notification_with_database(exception, controller, request, data={}, &block)
      exception_notification_without_database(exception, controller, request, data, &block)
    end

  end
  
end
ExceptionNotifier.send(:include, RedmineExceptionNotifierPatch)
ExceptionNotifier.send(:alias_method_chain, :exception_notification, :database)
ActionController::Base.send(:include, ExceptionNotifiable)
