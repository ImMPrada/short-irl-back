json.message "url shortened"

json.registered_url do
  json.partial! 'api/v1/partials/registered_url', registered_url: @registered_url
end
