class CreateReceiveds < ActiveRecord::Migration[6.1]
  def change
    create_table :receiveds do |t|
      t.string :channel_id
      t.string :text

      t.timestamps
    end
  end
end
