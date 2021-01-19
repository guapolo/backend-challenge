class PathsToExpertSerializer
  include FastJsonapi::ObjectSerializer
  set_id :id
  set_type :path_to_expert

  attributes :paths, :topic
end
