class Item
    def self.all
        items = Dir.entries("public/resources/example_models/").grep(/.json/).sort
        items.each_with_index do | item, index |
            item = item.chomp(".json")
            items[index] = item
        end
        items
    end 
end