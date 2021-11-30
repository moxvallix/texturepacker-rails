class DashboardController < ApplicationController
    def index
        @items = Item.all
        @selected_item = params[:selection]
    end

    def upload
        require 'fileutils'
        require 'json'
        require 'zip_file_generator'

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

        unless File.exist?(model_out + texture_name + ".json")
            FileUtils.cp(examples + selection, model_out)
            File.rename(model_out + selection, model_out + texture_name + ".json")
        end

        File.open(img_out + texture_name + ".png", 'wb') do |file|
            file.write(uploaded_file.read)
        end

        model_json = JSON.parse(File.read(models + selection))
        
        if has_overrides?(model_json)
            model_no = next_model_number(model_json)
            overrides = overrides | model_data(model_no, collection, texture_name)
            overrides = {"overrides" => overrides}
            output = model_json.merge(overrides)
        else
            model_no = 1
            output = model_json.merge({"overrides" => model_data(model_no, collection, texture_name)})
        end

        File.write(models + selection, JSON.pretty_generate(output))
        model_json = JSON.parse(File.read(model_out + texture_name + ".json"))
        texture_data = {"textures"=>{"layer0"=>"minecraft:item/#{collection}/#{texture_name}"}}
        output = model_json.merge(texture_data)

        File.write(model_out + texture_name + ".json", JSON.pretty_generate(output))

        folder = "storage/#{collection}/"
        zipfile = "public/packs/custom-rp.zip"

        if File.exists?(zipfile)
            File.delete(zipfile)
        end

        zf = ZipFileGenerator.new(folder, zipfile)
        zf.write

        redirect_to output_dashboard_index_path(uid: model_no, name: texture_name, item: selection)
    end

    def model_data(model_no, collection, texture_name)
        [{"predicate"=>{"custom_model_data"=>model_no}, "model"=>"item/#{collection}/#{texture_name}"}]
    end

    def has_overrides?(model_json)
        model_json.has_key?("overrides")
    end

    def next_model_number(model_json)
        overrides = model_json["overrides"]
        predicate = overrides.last
        model = predicate["predicate"]
        model["custom_model_data"].to_int + 1 
    end

    def download
        require 'open-uri'
        
        filepath = "public/packs/custom-rp.zip"

        send_file filepath
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

    def output
        @uid = params[:uid]
        @name = params[:name]
        @item = params[:item]
    end

end


