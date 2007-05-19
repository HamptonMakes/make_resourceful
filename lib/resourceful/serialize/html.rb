require 'resourceful/builder'

module Resourceful
  module Serialize
    class HTML
      def self.to_proc
        lambda {}
      end
    end
  end
end
