module Resourceful
  module Default
    module Actions
      def index
        load_objects
        before :index
        response_for :index
      end

      def show
        load_object
        before :show
        response_for :show
      end

      def create
        build_object
        load_object
        before :create
        if current_object.save
          save_succeeded!
          after :create
          response_for :create
        else
          save_failed!
          after :create_fails
          response_for :create_fails
        end
      end

      def update
        load_object
        before :update
        if current_object.update_attributes object_parameters
          save_succeeded!
          after :update
          response_for :update
        else
          save_failed!
          after :update_fails
          response_for :update_fails
        end
      end

      def new
        build_object
        load_object
        before :new
        response_for :new
      end

      def edit
        load_object
        before :edit
        response_for :edit
      end

      def destroy
        load_object
        before :destroy
        if load_object.destroy
          after :destroy
          response_for :destroy
        else
          after :destroy_fails
          response_for :destroy_fails
        end
      end
    end
  end
end
