class Friendship < ApplicationRecord
  after_create :reciprocate!
  after_destroy :unreciprocate!

  belongs_to :member
  belongs_to :friend, class_name: 'Member'

  validates :friend_id, uniqueness: { case_sensitive: false, scope: [:member_id] }

  private

  def reciprocated?
    self.class.exists?(inverse_attrs)
  end

  def inverse_attrs
    {
      member_id: friend_id,
      friend_id: member_id
    }
  end

  def reciprocate!
    return if reciprocated?

    self.class.create(inverse_attrs)
  end

  def unreciprocate!
    self.class.where(inverse_attrs).destroy_all
  end
end

# ## Schema Information
#
# Table name: `friendships`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `bigint`           | `not null, primary key`
# **`created_at`**              | `datetime`         | `not null`
# **`updated_at`**              | `datetime`         | `not null`
# **`friend_id(Friend UUID)`**  | `uuid`             | `not null`
# **`member_id(Member UUID)`**  | `uuid`             | `not null`
#
# ### Indexes
#
# * `index_friendships_on_friend_id`:
#     * **`friend_id`**
# * `index_friendships_on_member_id`:
#     * **`member_id`**
# * `index_friendships_on_member_id_and_friend_id` (_unique_):
#     * **`member_id`**
#     * **`friend_id`**
#
# ### Foreign Keys
#
# * `fk_rails_2ed7e67632`:
#     * **`member_id => members.id`**
# * `fk_rails_d78dc9c7fd`:
#     * **`friend_id => members.id`**
#
