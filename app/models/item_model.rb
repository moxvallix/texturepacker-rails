require 'json'

class ItemModel
    def self.all(collection)
        model_dir = "public/packs/#{collection}/assets/minecraft/models/item/"
        texture_dir = "/packs/#{collection}/assets/minecraft/textures/"
        unless Dir.exists?(model_dir)
            array = []
            output_hash = Hash.new
            output_hash = {"name" => "Please create an Item", "parent" => "------", "uid" => "!!!", "path" => "/packs/#{collection}/pack.png"}
            array.push(output_hash)
            return array
        end
        models = Dir.entries(model_dir).grep(/.json/).sort
        output = []
        models.each_with_index do |model, index|
            model_json = JSON.parse(File.read(model_dir + model))
            overrides = model_json["overrides"]
            overrides.each_with_index do |override, index|
                output_hash = Hash.new
                parent = model.chomp(".json").titlecase
                if override["predicate"].has_key?("custom_model_data")
                    predicate = override["predicate"]["custom_model_data"]
                    texture_path = texture_dir + override["model"].to_s + ".png"
                    split_name = override["model"].to_s.split('/')
                    name = split_name[2].titlecase
                    output_hash = {"name" => name, "parent" => parent, "uid" => predicate, "path" => texture_path}
                    output.push(output_hash)
                end
            end
        end
        output
    end
end