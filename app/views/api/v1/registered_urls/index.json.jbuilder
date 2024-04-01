json.array! @registered_urls do |registered_url|
  json.partial! 'api/v1/partials/registered_url', registered_url:
end
