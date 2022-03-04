class Item
    def self.all
        items = Dir.entries("public/resources/example_models/").grep(/.json/).sort
        items.each_with_index do | item, index |
            item = item.chomp(".json")
            items[index] = item
        end
        items
    end

    def self.find(name)
        model_name = name.parameterize.underscore
        "public/resources/example_models/#{model_name}.json"
    end

end