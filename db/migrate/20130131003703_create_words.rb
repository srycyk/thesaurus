class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :name
      t.boolean :proper_name, default: false
      t.boolean :noun, default: false
      t.boolean :verb, default: false
      t.boolean :adverb, default: false
      t.boolean :adjective, default: false
      t.boolean :typed, default: false

      #t.timestamps
    end
    add_index :words, :name
  end
end
