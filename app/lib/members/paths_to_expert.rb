# frozen_string_literal: true

module Members
  class PathsToExpert
    attr_reader :id, :paths, :topic

    def initialize(member, topic)
      @id = SecureRandom.alphanumeric(15)
      @paths = []
      @topic = topic

      ::Member.not_friends_with_topics(member, topic).each do |other_member|
        path = member.shortest_path_to(other_member)
        paths << path if path.present?
      end
    end
  end
end
