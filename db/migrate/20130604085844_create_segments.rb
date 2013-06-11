
class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.integer :phrase_id
      t.belongs_to :word
    end
    add_index :segments, :phrase_id
    add_index :segments, :word_id

    add_column :words, :segments_count, :integer, default: 0
  end
end
