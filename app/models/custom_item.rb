class CustomItem
    def self.all(collection)
        model_dir = "public/packs/#{collection}/assets/minecraft/models/item"

        items = Dir.entries(model_dir).grep(/.json/).sort
        items.each_with_index do | item, index |
            item = item.chomp(".json")
            items[index] = item
        end
        items
    end

    def self.find(collection, name)
        model_dir = "public/packs/#{collection}/assets/minecraft/models/item"
        model_name = name.parameterize.underscore
        "#{model_dir}/#{model_name}.json"
    end

    def self.find_parent(collection, name)
        model_dir = "public/packs/#{collection}/assets/minecraft/models/item"
        all(collection).each do | item |
            path = "#{model_dir}/#{item}.json"
            if File.readlines(path).grep(/"item\/#{collection}\/#{name}"/).any?
                return path
            end
        end
    end

end