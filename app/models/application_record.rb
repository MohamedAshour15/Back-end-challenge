class ApplicationRecord < ActiveRecord::Base
  include Swagger::Blocks
  self.abstract_class = true
end
