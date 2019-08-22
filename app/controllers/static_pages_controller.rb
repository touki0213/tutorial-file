class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost = current_user.microposts.build 
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def post
    @micropost = current_user.microposts.build 
  end

  def about

  end

  def contacttio
  end
end
