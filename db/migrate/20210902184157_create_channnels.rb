class CreateChannnels < ActiveRecord::Migration[6.1]
  def change
    create_table :channnels do |t|
      t.string :channel_id
      t.string :status

      t.timestamps
    end
  end
end
