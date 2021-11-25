class DashboardController < ApplicationController
    def index
        @items = Item.all
    end

    def upload
    end

    def search
        if params[:query].present?
          @items = Item.all.grep(/^#{params[:query]}/)
        else
          @items = Item.all
        end
    end 
end


