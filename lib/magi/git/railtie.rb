require "rails/railtie"

module Magi
  module Git
    class Railtie < Rails::Railtie
      config.after_initialize do
        require "magi/git/initializer"
      end
    end
  end
end
