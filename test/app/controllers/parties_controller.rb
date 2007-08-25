class PartiesController < ApplicationController
  make_resourceful do
    actions :show, :index
    
    publish :xml, :json, :yaml, :only => [:show], :attributes => [:name, {:people => [:name]}]
  end
end
