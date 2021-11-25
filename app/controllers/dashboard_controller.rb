require 'fileutils'

class DashboardController < ApplicationController
    def index
        @items = Item.all
        @selected_item = params[:selection]
    end

    def upload
      uploaded_file = params[:file]
      texture_name = params[:name]
      selection = params[:selection]

      collection = "custom"
      examples = "public/resources/example_models/"
      models = "storage/#{collection}/assets/minecraft/models/item/"
      model_out = "storage/#{collection}/assets/minecraft/models/item/#{collection}/"
      img_out = "storage/#{collection}/assets/minecraft/textures/item/#{collection}/"

      unless Dir.exists?(model_out)
        FileUtils.mkdir_p(model_out)
      end

      unless Dir.exists?(img_out)
        FileUtils.mkdir_p(img_out)
      end

      unless File.exist?(models + selection)
        FileUtils.cp(examples + selection, models)
      end

      File.open(img_out) do |file|
        file.write(uploaded_file.read)
      end

    end

    def search
        if params[:query].present?
          @items = Item.all.grep(/#{params[:query]}/)
        else
          @items = Item.all
        end
        
        render turbo_stream: turbo_stream.replace(
          'items',
          partial: 'items',
          locals: {
            items: @items
          }
        )
    end 
end


