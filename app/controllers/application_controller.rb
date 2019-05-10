class ApplicationController < ActionController::API
  include ExceptionHandler
  include ResponseHandler
  include Swagger::Blocks
end