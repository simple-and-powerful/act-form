# frozen_string_literal: true

require 'act_form/version'
require 'act_form/model'
require 'act_form/runnable'

require 'dry/schema'
Dry::Schema.load_extensions(:json_schema)

require 'act_form/schema/base'
require 'act_form/schema/extensions'
::Dry::Schema::DSL.include(::ActForm::Schema::Extensions::DSLExtension)
::Dry::Schema::Macros::DSL.include(::ActForm::Schema::Extensions::MacrosExtension)

module ActForm
  class Base
    include Model
  end

  class Command
    include Model
    include Runnable
    private_class_method :new
  end
end

I18n.load_path << "#{File.dirname(__FILE__)}/act_form/locale/en.yml"
I18n.load_path << "#{File.dirname(__FILE__)}/act_form/locale/zh-CN.yml"
