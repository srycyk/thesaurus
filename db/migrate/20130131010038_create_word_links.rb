class CreateWordLinks < ActiveRecord::Migration
  def change
    create_table :word_links do |t|
      t.integer :category
      t.belongs_to :definition
      t.belongs_to :word
    end
    add_index :word_links, :category
    add_index :word_links, :definition_id
    add_index :word_links, :word_id
  end
end
