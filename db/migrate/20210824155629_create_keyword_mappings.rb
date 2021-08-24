class CreateKeywordMappings < ActiveRecord::Migration[6.1]
  def change
    create_table :keyword_mappings do |t|
      t.string :channel_id
      t.string :keyword
      t.string :message

      t.timestamps
    end
  end
end
