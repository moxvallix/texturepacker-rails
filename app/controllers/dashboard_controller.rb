require 'fileutils'
require 'json'
require 'zip_file_generator'
require 'open-uri'

class DashboardController < ApplicationController
    def index
        collection = "custom"
        @item_models = ItemModel.all(collection)
    end

    def new
        @items = Item.all
        @selected_item = params[:selection]
    end

    def upload
        uploaded_file = params[:file]
        texture_name = params[:name].parameterize.underscore
        selection = params[:selection]
        if selection.empty? || selection == "Please select an Item"
            redirect_to new_dashboard_path(selection: "Please select an Item")
            return
        end
        item = selection
        selection = selection + ".json"
        collection = "custom"
        examples = "public/resources/example_models/"
        models = "public/packs/#{collection}/assets/minecraft/models/item/"
        model_out = "public/packs/#{collection}/assets/minecraft/models/item/#{collection}/"
        img_out = "public/packs/#{collection}/assets/minecraft/textures/item/#{collection}/"

        # Create correct folder structure
        FileUtils.mkdir_p(model_out) unless Dir.exists?(model_out)
        FileUtils.mkdir_p(img_out) unless Dir.exists?(img_out)
        FileUtils.cp(examples + selection, models) unless File.exist?(models + selection)
        unless File.exist?(model_out + texture_name + ".json")
            FileUtils.cp(examples + selection, model_out)
            File.rename(model_out + selection, model_out + texture_name + ".json")
        end

        # Determine core data
        model_json = JSON.parse(File.read(models + selection))
        model_no = next_model_number(model_json)

        # Saves updated base model to folder structure
        output = new_override(model_json, collection, texture_name, model_no)
        File.write(models + selection, JSON.pretty_generate(output))

        # Saves new child (override) model to folder structure
        model_out_json = JSON.parse(File.read(model_out + texture_name + ".json"))
        texture_data = {"textures"=>{"layer0"=>"minecraft:item/#{collection}/#{texture_name}"}}
        output = model_out_json.merge(texture_data)
        File.write(model_out + texture_name + ".json", JSON.pretty_generate(output))

        # Saves their image into the folder structure
        File.open(img_out + texture_name + ".png", 'wb') do |file|
            file.write(uploaded_file.read)
        end

        # Zips Collections
        zip_collection(collection)

        # Redirects to Output
        redirect_to output_dashboard_index_path(uid: model_no, name: texture_name, item: item)
    end

    def new_override(model_json, collection, texture_name, model_no)
        if has_overrides?(model_json)
            new_override = model_json["overrides"] | model_data(model_no, collection, texture_name)
            overrides = {"overrides" => new_override}
            model_json.merge(overrides)
        else
            model_json.merge({"overrides" => model_data(next_model_number(model_json), collection, texture_name)})
        end
    end

    def zip_collection(collection)
        folder = "public/packs/#{collection}/"
        zipfile = "public/packs/custom-rp.zip"
        File.delete(zipfile) if File.exists?(zipfile)
        zf = ZipFileGenerator.new(folder, zipfile)
        zf.write
    end

    def model_data(model_no, collection, texture_name)
        [{"predicate"=>{"custom_model_data"=>model_no}, "model"=>"item/#{collection}/#{texture_name}"}]
    end

    def has_overrides?(model_json)
        model_json.has_key?("overrides")
    end

    def has_custom_model?(model_json)
        if has_overrides?(model_json)
            overrides = model_json["overrides"]
            overrides.each do |override|
                if override["predicate"].has_key?("custom_model_data")
                    return true
                    puts "I have custom model"
                else
                    return false
                end
            end
        end
    end

    def next_model_number(model_json)
        return 1 unless has_custom_model?(model_json)
        predicate = model_json["overrides"].last
        model = predicate["predicate"]
        model["custom_model_data"].to_int + 1
    end

    def download
        collection = "custom"
        zip_collection(collection)
        filepath = "public/packs/#{collection}-rp.zip"
        send_file filepath
    end

    def search
        @items = Item.all
        if params[:query].present?
          item_list = Item.all
          search = params[:query].to_s.split(" ")
          search.each do |q|
            item_list = item_list.select {|s| s.match(/#{q}/)}
          end
          @items = item_list
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


