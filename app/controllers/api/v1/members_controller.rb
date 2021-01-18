module Api
  module V1
    class MembersController < JWTAuthorizationController
      before_action :set_member, only: [:show, :update, :destroy]

      def index
        @members = ::Member.all

        render json: ::MemberSerializer.new(@members, { is_collection: true })
      end

      def show
        render json: member_serializer
      end

      def create
        @member = ::Member.new(member_params)

        if @member.save
          render json: member_serializer, status: :created
        else
          render_app_error_code(
            code_id: '100',
            detail: @member.errors.full_messages.join(', ')
          )
        end
      end

      def update
        if @member.update(member_params)
          render json: member_serializer
        else
          render_app_error_code(
            code_id: '102',
            detail: @member.errors.full_messages.join(', ')
          )
        end
      end

      def destroy
        @member.destroy

        head :ok
      end

      private

      def set_member
        @member = ::Member.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_app_error_code(code_id: '101')
      end

      def member_params
        params.from_jsonapi.require(:member).permit(:name, :url)
      end

      def member_serializer
        ::MemberSerializer.new(@member, { is_collection: false })
      end
    end
  end
end
