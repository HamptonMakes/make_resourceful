module Resourceful
  module Default
    module Actions
      def index
        load_objects
        before_index
        response_for :index
      end

      def show
        load_object
        before_show
        response_for :show
      end

      def create
        build_object
        before_create
        if current_object.save
          after_create
          response_for :create
        else
          after_create_fails
          response_for :create_fails
        end
      end

      def update
        load_object
        before_update
        if current_object.update_attributes object_parameters
          after_update
          response_for :update
        else
          after_update_fails
          response_for :update_fails
        end
      end

      def new
        build_object
        before_new
        response_for :new
      end

      def edit
        load_object
        before_edit
        response_for :edit
      end

      def destroy
        load_object
        before_destroy
        if load_object.destroy
          after_destroy
          response_for :destroy
        else
          after_destroy_fails
          response_for :destroy_fails
        end
      end
    end
  end
end
