require 'act_form/version'
require 'act_form/model'
require 'act_form/runnable'

module ActForm
  class Base
    include Model
  end

  class Command < Base
    include Runnable
    private_class_method :new
  end
end

I18n.load_path << "#{File.dirname(__FILE__)}/act_form/locale/en.yml"
