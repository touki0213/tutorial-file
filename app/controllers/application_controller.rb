class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    include SessionsHelper  #Sessionヘルパーモジュールを読み込む

    private

    #ユーザーのログインを確認する
    def logged_in_user#createアクやdestroyアクに対するアクセス制限がbeforeフィルタで簡単に実装できるようする

      unless logged_in?
        store_location
        flash[:danger]="Please log in."
        redirect_to login_url
      end
    end    
  end
  