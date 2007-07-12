module Resourceful
  class Response
    attr :formats

    def initialize
      @formats = []
    end

    def method_missing(name, &block)
      @formats.push([name, block]) unless @formats.find{|n,b| n == name}
    end
  end
end
