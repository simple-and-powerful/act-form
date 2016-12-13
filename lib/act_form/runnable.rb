require 'active_support/concern'

module ActForm
  module Runnable
    extend ActiveSupport::Concern

    included do
      attr_reader :result
    end

    class_methods do
      def run(*args)
        new(*args).run
      end
    end

    def has_errors?
      !errors.empty?
    end

    def run
      if valid?
        @result    = perform
        @performed = true
      end
      self
    end

    def perform; end

    def success?
      !has_errors? && !!@performed
    end

    def failure?
      !success?
    end
  end
end
