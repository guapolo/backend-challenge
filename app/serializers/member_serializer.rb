class MemberSerializer
  include FastJsonapi::ObjectSerializer
  set_id :id
  set_type :member

  attribute :friends_count do |obj|
    obj.friends.size
  end

  attribute :friends_pages do |obj|
    obj.friends.pluck(:url)
  end

  attribute :headings do |obj|
    obj.headings.pluck(:text)
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
# **`name(Name)`**                        | `text`             | `not null`
# **`short_url(Shortened website URL)`**  | `text`             |
# **`url(Website URL)`**                  | `text`             | `not null`
# **`created_at`**                        | `datetime`         | `not null`
# **`updated_at`**                        | `datetime`         | `not null`
#
