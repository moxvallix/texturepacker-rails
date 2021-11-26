class CreateTextures < ActiveRecord::Migration[7.0]
  def change
    create_table :textures do |t|
      t.integer :uid
      t.string :name
      t.string :origin

      t.timestamps
    end
  end
end
