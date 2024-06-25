require 'minitest/autorun'
require 'rack/test'
require 'act_form'
require 'grape'

class FooService < ActForm::Command
  params do
    required(:name).filled
  end

  def perform
    'hello ' + name
  end
end

module WorkWithGrapeSpec
  class API < Grape::API
    format :json

    contract FooService.contract
    get '/foo' do
      FooService.run(params).perform
    end

    contract FooService.contract do
      required(:age).filled
    end
    get '/bar' do
      FooService.run(params).perform
    end
  end
end

class WorkWithGrapeSpec::APITest < Minitest::Test
  include Rack::Test::Methods

  def app
    WorkWithGrapeSpec::API
  end

  def test_if_params_missing
    get '/foo'
    assert_equal 400, last_response.status
    d = JSON.parse(last_response.body)
    assert_equal 'name is missing', d['error']
  end

  def test_it_works
    get '/foo', name: 'foo'
    assert_equal 200, last_response.status
    assert_equal '"hello foo"', last_response.body
  end

  def test_it_works_with_nested_contract
    get '/bar', name: 'foo'
    assert_equal 400, last_response.status
    d = JSON.parse(last_response.body)
    assert_equal 'age is missing', d['error']

    get '/bar', age: 18
    assert_equal 400, last_response.status
    d = JSON.parse(last_response.body)
    assert_equal 'name is missing', d['error']

    get '/bar', name: 'foo', age: 18
    assert_equal 200, last_response.status
    assert_equal '"hello foo"', last_response.body
  end
end
