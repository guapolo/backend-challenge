FactoryBot.define do
  factory :friendship do
    member { nil }
    friend { nil }
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
