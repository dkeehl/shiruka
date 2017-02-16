ENV['RACK_ENV'] = 'test'

require File.expand_path('../../control', __FILE__)
require 'minitest/autorun'
require 'rack/test'

class GetResponseTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Shiruka
  end

  def test_it_responses_to_home
    get '/'
    assert last_response.redirect?
    follow_redirect!
    assert_equal '/explore', last_request.path
  end

  def test_it_responses_to_explore
    get '/explore'
    assert last_response.ok?
  end

  def test_it_responses_to_login
    get '/login'
    assert last_response.ok?
  end

end
