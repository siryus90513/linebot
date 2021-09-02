class CreateChannelStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :channel_statuses do |t|
      t.string :status
      t.string :channelid

      t.timestamps
    end
  end
end
