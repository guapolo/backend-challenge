class Member < ApplicationRecord
  after_create :enqueue_creation_jobs

  validates :name, presence: true
  validates :url, presence: true, url: true

  has_many :friendships
  has_many :friends, -> { order(:name) }, through: :friendships, dependent: :destroy
  has_many :headings, -> { order(:text) }, inverse_of: :member, dependent: :destroy

  private

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
