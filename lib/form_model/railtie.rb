module FormModel
  class Railtie < ::Rails::Railtie
    generators do
      require 'generators/form_model/install_generator'
    end
  end
end
