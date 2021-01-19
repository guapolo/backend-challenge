class Member < ApplicationRecord
  after_create :enqueue_creation_jobs

  validates :name, presence: true
  validates :url, presence: true, url: true

  has_many :friendships
  has_many :friends, through: :friendships, dependent: :destroy do
    def ordered_by_name
      order(:name)
    end
  end
  has_many :headings, inverse_of: :member, dependent: :destroy do
    def ordered
      order(:text)
    end
  end

  scope :not_friends, ->(member) do
    where.not(id: member.friend_ids)
      .where.not(id: member.id)
  end

  scope :topics, ->(topic) do
    joins(:headings).merge(Heading.search_by_text(topic))
  end

  scope :not_friends_with_topics, ->(member, topic) do
    select('*').distinct(:member_id).from(not_friends(member).topics(topic))
  end

  def shortest_path_to(other_member, to_visit = nil, possible_paths = [])
    return [] if id == other_member.id || friend_ids.empty?
    return [name, other_member.name] if friend_ids.include?(other_member.id)

    to_visit = Set.new(self.class.where.not(id: id).order(:id).pluck(:id)) unless to_visit
    to_visit.delete(id)

    shortest_friends_path(other_member, to_visit, possible_paths)
  end

  def path_to(other_member, to_visit = nil)
    return [] if id == other_member.id || friend_ids.empty?
    return [name, other_member.name] if friend_ids.include?(other_member.id)

    to_visit = Set.new(self.class.where.not(id: id).order(:id).pluck(:id)) unless to_visit
    to_visit.delete(id)

    friends_path(other_member, to_visit)
  end

  private

  def friends_path(other_member, to_visit)
    friends.ordered_by_name.where(id: to_visit).each do |friend|
      path = friend.path_to(other_member, to_visit)

      return [name] + path if path.include?(other_member.name)
    end

    return []
  end

  def shortest_friends_path(other_member, to_visit, possible_paths)
    friends.ordered_by_name.where(id: to_visit).each do |friend|
      path = friend.shortest_path_to(other_member, to_visit)

      possible_paths << [name] + path if path.include?(other_member.name)
    end

    return possible_paths.min { |a,b| a.size <=> b.size } if possible_paths.size > 0

    return []
  end

  def enqueue_creation_jobs
    ::Members::Website::UrlShortenerWorker.perform_async(id)
    ::Members::Website::HeadingExtractionWorker.perform_async(id)
  end
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
