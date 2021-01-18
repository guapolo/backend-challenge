class MemberSerializer
  include FastJsonapi::ObjectSerializer

  set_id :id
  set_type :member

  attribute :friend_count do |obj|
    obj.friends.size
  end
  attributes :name, :short_url, :url
end

# ## Schema Information
#
# Table name: `members`
#
# ### Columns
#
# Name                                    | Type               | Attributes
# --------------------------------------- | ------------------ | ---------------------------
# **`id`**                                | `uuid`             | `not null, primary key`
# **`friend_count(Number of friends)`**   | `integer`          | `default(0), not null`
# **`name(Name)`**                        | `text`             | `not null`
# **`short_url(Shortened website URL)`**  | `text`             |
# **`url(Website URL)`**                  | `text`             | `not null`
# **`created_at`**                        | `datetime`         | `not null`
# **`updated_at`**                        | `datetime`         | `not null`
#
