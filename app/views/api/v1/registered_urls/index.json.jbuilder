json.array! @registered_urls do |registered_url|
  json.short_version registered_url.uuid
  json.url registered_url.url
  json.expires_at registered_url.expires_at
end
