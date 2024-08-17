json.user do
  json.partial! 'users/partials/user_session_data', user: @user
end
