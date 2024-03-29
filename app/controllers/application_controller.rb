class ApplicationController < ActionController::API
  # Devise controllers need functionality provided by this module in production mode
  include ActionController::MimeResponds

  before_action :jsonify

private

  def current_user
    # Return the current user if we've already set one
    return @_current_user if @_current_user

    # Otherwise, look it up via api key sent in the AUTH_TOKEN header
    # Note: if this header isn't set, we should probably fall back on using the
    #   built in Devise auth handling
    # Also note: your client will probably want to set the header AUTH_TOKEN (even though
    #   it's read as HTTP_AUTH_TOKEN)
    token = request.headers["HTTP_AUTH_TOKEN"]

    # Look up the key (raises 404 if not found, which isn't the _best_ way to handle that)
    key = ApiKey.where(token: token).first!

    # Set the user for future calls
    @_current_user = key.user
  end

  def render_invalid obj
    # Helper to send back an invalid object message with the right status code
    render json: { errors: obj.errors.full_messages }, status: 422
  end

  def jsonify
    # Coerce all requests into JSON format
    # Should probably only do this if the request format isn't already
    #   explicitly set
    request.format = :json
  end

end
