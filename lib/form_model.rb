require 'form_model/version'
require 'form_model/model'

module FormModel
  class Base
    include Model
  end
end

require 'form_model/railtie' if defined?(Rails)
