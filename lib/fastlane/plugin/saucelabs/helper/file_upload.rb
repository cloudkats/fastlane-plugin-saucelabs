require "uri"
require "net/http"
#TODO: test all the methods

class SauceHttp
  def initialize(ui, username, apikey, region)
    @UI = ui
    encoded_auth = Base64::strict_encode64(username + ":" + apikey)
    @basic_auth_key = "Basic #{encoded_auth}"
    endpoints = {
      'us' => "https://api.us-west-1.saucelabs.com",
      'us-west-1' => "https://api.us-west-1.saucelabs.com",
      'eu' => "https://api.eu-central-1.saucelabs.com",
      'eu-central-1' => "https://api.eu-central-1.saucelabs.com"
    }
    @region = case region
              when 'eu' then "eu-central-1"
              when 'us' then "us-west-1"
              else region
              end
    @endpoint = endpoints[region]
    @UI.message("DEBUG: BASE URL #{@endpoint}") if ENV['DEBUG']
  end

  def is_access_authorized(resource_path = 'team-management/v1/teams/')
    @UI.message("DEBUG: GET(authorization) #{@endpoint}/#{resource_path}") if ENV['DEBUG']
    https, url = request_prepare(resource_path)
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = @basic_auth_key
    response = https.request(request)
    response.kind_of?(Net::HTTPOK)
    unless response.kind_of?(Net::HTTPOK)
      raise "Auth Error, provided invalid username or token"
    end
  end

  def is_available(resource_path = 'rest/v1/info/status')
    @UI.message("DEBUG: GET(platform status) #{@endpoint}/#{resource_path}") if ENV['DEBUG']
    https, url = request_prepare(resource_path)
    request = Net::HTTP::Get.new(url)
    response = https.request(request)
    body = JSON.parse(response.body)
    unless response.kind_of?(Net::HTTPOK) && body['service_operational']
      raise "Service #{@endpoint}/#{resource_path} is not operational. #{body['status_message']}"
    end
  end

  def upload(app_name, app_description, payload, size, resource_path = 'v1/storage/upload')
    @UI.message("DEBUG: POST(artifact upload) #{@endpoint}/#{resource_path}") if ENV['DEBUG']

    https, url = request_prepare(resource_path)
    request = Net::HTTP::Post.new(url)
    request["Authorization"] = @basic_auth_key
    request['Content-Length'] = size
    request['Accept'] = '*/*'
    form_data = [['payload', payload], ['name', app_name]]
    request.set_form form_data, "multipart/form-data"
    response = https.request(request)
    body = JSON.parse(response.body)

    case response.code.to_i
    when 406
      raise "#{body['title']}. #{body['detail']}"
    end

    item = body['item']
    if app_description and !app_description.to_s.strip.empty?
      update_description(item['id'], app_description)
    end

    {
      id: item['id'],
      kind: item['kind'],
      name: item['name'],
      size: size,
      region: @region
    }
  end

  def update_description(id, app_description)
    resource_path = "v1/storage/files/#{id}"
    @UI.message("DEBUG: PUT(artifact update) #{@endpoint}/#{resource_path}/#{id}") if ENV['DEBUG']
    @UI.message("DEBUG: PUT(artifact update) app description #{app_description}") if ENV['DEBUG']

    https, url = request_prepare(resource_path)
    request = Net::HTTP::Put.new(url)
    request["Authorization"] = @basic_auth_key
    request["Content-Type"] = "application/json"
    request.body = JSON.dump({
                               "item": {
                                 "description": app_description
                               }
                             })

    response = https.request(request)

    unless response.kind_of?(Net::HTTPOK)
      body = JSON.parse(response.body)
      case response.code.to_i
      when 404
        raise "#{body['title']}. #{body['detail']}"
      end
      raise "Unhandled exception. #{body}"
    end
  end

  private

  def request_prepare(resource_path)
    url = URI("#{@endpoint}/#{resource_path}")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    [https, url]
  end
end
