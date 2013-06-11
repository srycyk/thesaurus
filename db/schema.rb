# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130604085844) do

  create_table "definitions", :force => true do |t|
    t.integer "word_links_count", :default => 0
    t.integer "word_id"
  end

  add_index "definitions", ["word_id"], :name => "index_definitions_on_word_id"

  create_table "segments", :force => true do |t|
    t.integer "phrase_id"
    t.integer "word_id"
  end

  add_index "segments", ["phrase_id"], :name => "index_segments_on_phrase_id"
  add_index "segments", ["word_id"], :name => "index_segments_on_word_id"

  create_table "word_links", :force => true do |t|
    t.integer "category"
    t.integer "definition_id"
    t.integer "word_id"
  end

  add_index "word_links", ["category"], :name => "index_word_links_on_category"
  add_index "word_links", ["definition_id"], :name => "index_word_links_on_definition_id"
  add_index "word_links", ["word_id"], :name => "index_word_links_on_word_id"

  create_table "words", :force => true do |t|
    t.string  "name"
    t.boolean "proper_name",    :default => false
    t.boolean "noun",           :default => false
    t.boolean "verb",           :default => false
    t.boolean "adverb",         :default => false
    t.boolean "adjective",      :default => false
    t.boolean "typed",          :default => false
    t.integer "segments_count", :default => 0
  end

  add_index "words", ["name"], :name => "index_words_on_name"

end
