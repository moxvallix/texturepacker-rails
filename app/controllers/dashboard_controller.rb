require 'fileutils'
require 'json'
require 'zip_file_generator'
require 'open-uri'

class DashboardController < ApplicationController
    COLLECTION = "custom"

    def index
        @item_models = ItemModel.list(COLLECTION)
    end

    def new
        @items = Item.all
        @selected_item = params[:selection]
        @items_type = "new"
    end

    def edit
        @items = CustomItem.all(COLLECTION)
        @selected_item = params[:selection]
        unless @selected_item.nil?
            @model_file = CustomItem.find(COLLECTION, @selected_item)
            @model_json = File.read(@model_file)
        end
        @items_type = "edit"
    end

    def edit_items
        @items = ItemModel.all(COLLECTION)
        @selected_item = params[:selection]
        unless @selected_item.nil?
            @model_file = ItemModel.find(COLLECTION, @selected_item)
            @texture_path = ItemModel.find_texture(COLLECTION, @selected_item)
            @model_json = File.read(@model_file)
        end
        @items_type = "items"
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
        models = "public/packs/#{COLLECTION}/assets/minecraft/models/item/"
        model_out = "public/packs/#{COLLECTION}/assets/minecraft/models/item/#{COLLECTION}/"
        img_out = "public/packs/#{COLLECTION}/assets/minecraft/textures/item/#{COLLECTION}"

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
        output = new_override(model_json, COLLECTION, texture_name, model_no)
        File.write(models + selection, JSON.pretty_generate(output))

        # Saves new child (override) model to folder structure
        model_out_json = JSON.parse(File.read(model_out + texture_name + ".json"))
        texture_data = {"textures"=>{"layer0"=>"minecraft:item/#{COLLECTION}/#{texture_name}"}}
        output = model_out_json.merge(texture_data)
        File.write(model_out + texture_name + ".json", JSON.pretty_generate(output))

        # Saves their image into the folder structure
        texture_path = "#{img_out}/#{texture_name}.png"
        File.open(texture_path, 'wb') do |file|
            file.write(uploaded_file.read)
        end

        # Generate a .mcmeta file if the texture is to be animated
        dimensions = IO.read(texture_path)[0x10..0x18].unpack('NN')
        if dimensions[1] > dimensions[0]
            FileUtils.cp("public/resources/animation.mcmeta", "#{img_out}/#{texture_name}.png.mcmeta")
        end

        # Zips Collections
        zip_collection(COLLECTION)

        # Redirects to Output
        redirect_to output_dashboard_index_path(uid: model_no, name: texture_name, item: item)
    end

    def model
        selected_item = params[:selection]
        model_file = CustomItem.find(COLLECTION, selected_item)

        model_json = params[:model_json]

        File.write(model_file, model_json)
        redirect_to root_path
    end

    def items_model
        model_out = "public/packs/#{COLLECTION}/assets/minecraft/models/item/#{COLLECTION}"
        img_out = "public/packs/#{COLLECTION}/assets/minecraft/textures/item/#{COLLECTION}"
        selected_item = params[:selection]
        model_name = params[:name].parameterize.underscore
        texture = params[:file]
        model_json = params[:model_json]

        model_file = ItemModel.find(COLLECTION, selected_item)

        if selected_item != model_name
            base_model = CustomItem.find_parent(COLLECTION, selected_item)
            puts "Base: " + base_model
            base_text = File.read(base_model)
            base_text.sub! "item/#{COLLECTION}/#{selected_item}", "item/#{COLLECTION}/#{model_name}"
            File.delete(base_model)
            File.write(base_model, base_text)

            model_json.sub! "item/#{COLLECTION}/#{selected_item}", "item/#{COLLECTION}/#{model_name}"

            File.rename("#{img_out}/#{selected_item}.png", "#{img_out}/#{model_name}.png")
            File.delete(model_file)
            model_file = "#{model_out}/#{model_name}.json"
        end

        if texture.present?
            img_path = "#{img_out}/#{model_name}"
            File.delete(img_path)
            File.open(img_path, 'wb') do |file|
                file.write(texture.read)
            end
        end

        puts model_file
        File.write(model_file, model_json)
        redirect_to root_path
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
        [{"predicate"=>{"custom_model_data"=>model_no}, "model"=>"item/#{COLLECTION}/#{texture_name}"}]
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
        filepath = "public/packs/#{COLLECTION}-rp.zip"
        send_file filepath
    end

    def search
        @items_type = params[:items_type]

        case @items_type
        when "new"
            @items = Item.all
        when "edit"
            @items = CustomItem.all(COLLECTION)
        when "items"
            @items = ItemModel.all(COLLECTION)
        end

        if params[:query].present?
          item_list = @items
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
            items: @items,
            items_type: @items_type
          }
        )
    end

    def output
        @uid = params[:uid]
        @name = params[:name]
        @item = params[:item]
    end

end


