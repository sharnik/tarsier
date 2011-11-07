require 'loris'
require 'rails'

module MyPlugin
  class Railtie < Rails::Railtie
    railtie_name :loris

    rake_tasks do
      load "tasks/loris.rake"
    end
  end
end
