class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.integer :mention_user_id
      t.integer :micropost_id
      t.timestamps
    end

    add_index :mentions, [:mention_user_id, :micropost_id], unique: true
    add_index :mentions,  :micropost_id
  end
end