module FormModel
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      desc 'Create the forms dir and copy record_form.rb'
      def copy_initializer
        directory 'forms', 'app/forms'
      end
    end
  end
end
