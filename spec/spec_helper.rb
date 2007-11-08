$: << File.dirname(__FILE__) + '/../lib'
%w[rubygems spec action_pack active_record resourceful/maker
   action_controller action_controller/test_process action_controller/integration].each &method(:require)

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

def should_be_called(&block)
  pstub = stub
  pstub.expects(:call).instance_eval(&(block || proc {}))
  proc { |*args| pstub.call(*args) }
end

def stub_model(name)
  model = Class.new do
    include Resourceful::Serialize::Model

    def self.to_s
      @name
    end

    def initialize(attrs = {})
      attrs.each do |k, v|
        self.stubs(k).returns(v)
      end
    end

    def inspect
      "#<#{self.class.send(:instance_variable_get, '@name')}>"
    end
  end
  model.send(:instance_variable_set, '@name', name)
  model
end

def stub_const(name)
  Object.const_set(name, stub(name.to_s)) unless Object.const_defined?(name)
  Object.const_get(name)
end

def stub_list(size, name = nil)
  Array.new(size) { |i| name ? stub("#{name}_#{i}") : stub }
end

module Spec::Matchers
  def have_any(&proc)
    satisfy { |a| a.any?(&proc) }
  end
end

module ControllerMocks
  def mock_kontroller(*to_extend)
    options = to_extend.last.is_a?(Hash) ? to_extend.slice!(-1) : {}
    @kontroller = Class.new
    @kontroller.extend Resourceful::Maker
    to_extend.each(&@kontroller.method(:extend))

    @hidden_actions = Resourceful::ACTIONS.dup
    @kontroller.stubs(:hidden_actions).returns(@hidden_actions)
    @kontroller.stubs(:plural_action?).returns(false)
    @kontroller.stubs(:include)
    @kontroller.stubs(:before_filter)
    @kontroller.stubs(:helper_method)
  end

  def mock_controller(*to_extend)
    mock_kontroller
    @controller = @kontroller.new
    to_extend.each(&@controller.method(:extend))
  end

  def mock_builder
    @builder = stub
    @builder.stubs(:response_for)
    @builder.stubs(:apply)
    @builder.stubs(:instance_eval).yields(@buildercc )
    Resourceful::Base.stubs(:made_resourceful).returns([])
    Resourceful::Builder.stubs(:new).returns(@builder)
  end

  def create_builder
    @builder = Resourceful::Builder.new(@kontroller)
    class << @builder
      alias_method :made_resourceful, :instance_eval
    end    
  end

  def responses
    @kontroller.read_inheritable_attribute(:resourceful_responses)
  end

  def callbacks
    @kontroller.read_inheritable_attribute(:resourceful_callbacks)
  end

  def parents
    @kontroller.read_inheritable_attribute(:parents)
  end

  # Evaluates the made_resourceful block of mod (a module)
  # in the context of @builder.
  # @builder should be initialized via create_builder.
  def made_resourceful(mod)
    mod.included(@builder)
  end
end

module RailsMocks
  attr_reader :response, :request, :controller, :kontroller

  def mock_resourceful(options = {}, &block)
    options = {
      :name => "things"
    }.merge options

    init_kontroller options
    init_routes options

    stub_const(options[:name].singularize.camelize)
    kontroller.make_resourceful(&block)

    init_controller options
  end

  def assigns(name)
    controller.instance_variable_get("@#{name}")
  end

  private

  def init_kontroller(options)
    @kontroller = Class.new ActionController::Base
    @kontroller.extend Resourceful::Maker

    @kontroller.metaclass.send(:define_method, :controller_name) { options[:name] }
    @kontroller.metaclass.send(:define_method, :controller_path) { options[:name] }
    @kontroller.metaclass.send(:define_method, :inspect) { "#{options[:name].camelize}Controller" }
    @kontroller.metaclass.send(:alias_method, :to_s, :inspect)

    @kontroller.send(:define_method, :controller_name) { options[:name] }
    @kontroller.send(:define_method, :controller_path) { options[:name] }
    @kontroller.send(:define_method, :inspect) { "#<#{options[:name].camelize}Controller>" }
    @kontroller.send(:alias_method, :to_s, :inspect)
    @kontroller.send(:include, ControllerMethods)

    @kontroller
  end

  def init_routes(options)
    ActionController::Routing::Routes.clear!
    route_block = options[:routes] || proc { |map| map.resources options[:name] }
    ActionController::Routing::Routes.draw(&route_block)
  end
  
  def init_controller(options)
    @controller = kontroller.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

    @controller.request = @request
    @controller.response = @response
    @request.accept = '*/*'

    @controller
  end

  module ControllerMethods
    def render(options=nil, deprecated_status=nil, &block)
      unless block_given?
        @template.metaclass.class_eval do
          define_method :file_exists? do true end
          define_method :render_file do |*args|
            @first_render ||= args[0]
          end
        end
      end

      super(options, deprecated_status, &block)
    end
  end
end
