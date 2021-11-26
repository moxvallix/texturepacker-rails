require 'fileutils'
require 'json'

class DashboardController < ApplicationController
    def index
        @items = Item.all
        @selected_item = params[:selection]
    end

    def upload
        uploaded_file = params[:file]
        texture_name = params[:name]
        selection = params[:selection]

        selection = selection + ".json"

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

        File.open(img_out + texture_name + ".png", 'wb') do |file|
            file.write(uploaded_file.read)
        end

        model_no = (rand() * 9000000).to_i

        model_json = JSON.parse(File.read(models + selection))
        model_data = [{"predicate"=>{"custom_model_data"=>model_no}, "model"=>"item/#{collection}/#{texture_name}.json"}]
        
        if model_json.has_key?("overrides")
            overrides = model_json["overrides"]
            overrides = overrides | model_data
            overrides = {"overrides"=>overrides}
            output = model_json.merge(overrides)
        else
            output = model_json.merge({"overrides"=>model_data})
        end

        File.write(models + selection, JSON.pretty_generate(output))

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


