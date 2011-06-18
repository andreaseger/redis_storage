require 'rails/generators'
require 'rails/generators/named_base'

module RailsRecord
  module Generators
    class RedisGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('../../templates', __FILE__)
      argument :attrs, :type => :array, :default => [], :banner => "field field"
      check_class_collision
      desc "This generator creates an model for redis"

      def create_model_file
        a = ''
        a = ', :' << attrs.join(', :') unless attrs.empty?
        template 'model.rb', File.join('app/models',class_path,"#{file_name}.rb")
      end
    end
  end
end
