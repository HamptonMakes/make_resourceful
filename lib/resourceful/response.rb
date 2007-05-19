module Resourceful
  class Response
    attr :formats

    def initialize
      @formats = {}
    end

    def method_missing(name, block)
      @formats[name] = block
    end
  end
end
