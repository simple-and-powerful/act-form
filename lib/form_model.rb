require 'form_model/version'
require 'form_model/model'
require 'form_model/runnable'

module FormModel
  class Base
    include Model
  end

  class Command < Base
    include Runnable
    private_class_method :new
  end
end

I18n.load_path << "#{File.dirname(__FILE__)}/form_model/locale/en.yml"
