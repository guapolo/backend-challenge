class CreateFriendships < ActiveRecord::Migration[6.1]
  def change
    create_table :friendships do |t|
      t.references :member, null: false, foreign_key: true, type: :uuid, comment: 'Member UUID'
      t.uuid  :friend_id, null: false, index: true, comment: 'Friend UUID'

      t.timestamps
    end

    add_foreign_key :friendships, :members, column: :friend_id
    add_index :friendships, [:member_id, :friend_id], unique: true
  end
end
