module Api
  module V1
    class FriendshipsController < ApplicationController
      def create
        member = ::Member.find_by(name: friendship_params[:member_name])
        friend = ::Member.find_by(name: friendship_params[:friend_name])

        if member.present? && friend.present?
          @friendship = ::Friendship.new(member: member, friend: friend)

          if @friendship.save
            head :created
          else
            render_app_error_code(
              code_id: '200',
              detail: @friendship.errors.full_messages.join(', ')
            )
          end
        elsif member.blank?
          render_app_error_code(
            code_id: '200',
            detail: "Unable to find member: #{friendship_params[:member_name]}"
          )
        elsif friend.blank?
          render_app_error_code(
            code_id: '200',
            detail: "Unable to find member: #{friendship_params[:friend_name]}"
          )
        end
      end

      private

      def friendship_params
        @friendship_params ||= params.from_jsonapi.require(:friendship).permit(:member_name, :friend_name)
      end
    end
  end
end
