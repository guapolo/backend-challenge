module Api
  module V1
    class PathsToExpertsController < JWTAuthorizationController
      def search
        member = ::Member.find_by(name: member_topic_params[:member_name])
        topic = member_topic_params[:topic]

        if member && topic
          paths_to_expert = ::Members::PathsToExpert.new(member, topic)
          render json: ::PathsToExpertSerializer.new(paths_to_expert, {is_collection: false}), status: :ok
        elsif member.blank?
          render_app_error_code(code_id: '101')
        elsif topic.blank?
          render_app_error_code(code_id: '300')
        end
      end

      private

      def member_topic_params
        params.from_jsonapi.require(:member_topic).permit(:member_name, :topic)
      end
    end
  end
end
