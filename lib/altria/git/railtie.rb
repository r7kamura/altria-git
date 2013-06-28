require "rails/railtie"

module Altria
  module Git
    class Railtie < Rails::Railtie
      config.after_initialize do
        require "altria/git/initializer"
      end
    end
  end
end
