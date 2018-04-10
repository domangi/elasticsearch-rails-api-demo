module Api
  module V1
    class MoviesController < ApplicationController
      def index
        if request.get?
          result = Movie.custom_search(search_params[:search], search_params[:filters].to_h)
          if result
            page = params[:page]||1
            result = result.page(page)
            render json: {"movies": result}, status: 201
          else
            render status: 505
          end
        else
          render status: 404
        end
      end

      private

      def search_params
        params.permit(:search, :page, filters: [vote_average: [:gt]])
      end
    end
  end
end
