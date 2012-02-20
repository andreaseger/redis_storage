require 'spec_helper'
require 'rails/all'
require './lib/generators/rails/redis_generator'
require "generator_spec/test_case"

describe ::Rails::Generators::RedisGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path "../../tmp", __FILE__
  arguments %w(Schedule title body created_at)
  before(:all) do
    prepare_destination
    run_generator
  end
  specify "model" do
    destination_root.should have_structure {
      directory 'app' do
        directory 'models' do
          file 'schedule.rb' do
            contains "class Schedule < RedisStorage::Model"
            contains "attr_accessor *attrs"
            contains "def self.attr"
            contains "[ :id, :title, :body, :created_at ]"
          end
        end
      end
    }
  end
end
