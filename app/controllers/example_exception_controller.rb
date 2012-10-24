class ExampleExceptionController < ApplicationController
  unloadable
  
  def index
    raise Exception, 'Example exception'
  end
end
