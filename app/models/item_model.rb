require 'json'

class ItemModel
    def self.all(collection)
        model_dir = "public/packs/#{collection}/assets/minecraft/models/item/"
        texture_dir = "/packs/#{collection}/assets/minecraft/textures/"
        models = Dir.entries(model_dir).grep(/.json/).sort
        output = []
        models.each_with_index do |model, index|
            model_json = JSON.parse(File.read(model_dir + model))
            overrides = model_json["overrides"]
            overrides.each_with_index do |override, index|
                output_hash = Hash.new
                parent = model.chomp(".json").titlecase
                predicate = override["predicate"]["custom_model_data"]
                texture_path = texture_dir + override["model"].to_s + ".png"
                name = override["model"].to_s
                output_hash = {"parent" => parent, "uid" => predicate, "path" => texture_path}
                output.push(output_hash)
            end
        end
        output
    end
end