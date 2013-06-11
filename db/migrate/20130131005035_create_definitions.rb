class CreateDefinitions < ActiveRecord::Migration
  def change
    create_table :definitions do |t|
      t.integer :word_links_count, default: 0
      t.belongs_to :word

      #t.timestamps
    end
    add_index :definitions, :word_id
  end
end
