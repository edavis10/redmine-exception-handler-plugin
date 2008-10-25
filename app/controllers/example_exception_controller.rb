class ExampleExceptionController < ApplicationController
  unloadable
  
  local_addresses.clear
  
  def index
    raise Exception, 'Example exception'
  end
end
