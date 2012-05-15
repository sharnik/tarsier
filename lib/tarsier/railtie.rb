require 'tarsier'
require 'rails'

module MyPlugin
  class Railtie < Rails::Railtie
    railtie_name :tarsier

    rake_tasks do
      load "tasks/tarsier.rake"
    end
  end
end
