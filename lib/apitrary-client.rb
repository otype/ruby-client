#!/usr/bin/env ruby
require "rubygems"
require "bundler"
Bundler.setup

require "httparty"
require "json"

require "pp"
require "logger"

class ApitraryClient
  include HTTParty

  # comment this in to see HTTP request/response output from HTTParty
  # debug_output $stdout
  # format :json

  @private
  LOG = Logger.new(STDOUT)
  LOG.level = Logger::INFO

  # Creates a new {ApitraryClient} instance.
  # @param [String] base_uri    Base URL at which your API resides
  # @param [String] api_key     API key of associated to this API
  # @return [ApitraryClient] new instance of ApitraryClient
  def initialize(base_url, api_key)
    # the base_uri provided by HTTParty is a class variable and
    # therefore not suitable for the purpose of having multiple 
    # instances of the ApitraryClient which connect to different
    # base URLs
    @my_base_url = base_url
    # ApitraryClient.base_uri(base_uri)
    # base_uri(base_uri)

    # always send the API key
    # ApitraryClient.default_params(:api_key => api_key)
    # ApitraryClient.headers("X-Api-Key" => api_key)
    @my_headers = {
      "X-Api-Key" => api_key,
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "User-Agent" => "Ruby Client"
    }

    @status = status()
    # @resources_path = "#{@status["status"]["api"]["api_id"]}/v1"
    # @base_uri = base_uri
    @resources = @status["schema"]
    LOG.debug "Initializing client with resouces: #{@resources}"
  end

  # Status information about the apitrary API that this client is connected to
  # @return [Hash] status information about your API
  def status
    self.class.get(
      "#{@my_base_url}/", 
      :headers => @my_headers)
    # response = self.class.get("/")
    # case response.code
    #   when 200
    #     return response
    #   else
    #     raise "#{response["statusMessage"]} (Status code: #{response["statusCode"]})"
    # end
  end

  # Adds a new object to the resource
  # @param [String] resource    Name of the resource
  # @param [Object] object      Object to be added
  # @return [Hash] containing result, statusCode and statusMessage
  def add(resource, object)
    LOG.debug "add: #{resource}"
    raise "Invalid resource" if not valid_resource?(resource)

    # https://groups.google.com/forum/?fromgroups=#!topic/httparty-gem/4sA4YxakqSU
    # options = { :body => JSON.dump(object), :headers => @my_headers}
    self.class.post(
      "#{@my_base_url}/#{resource}", 
      :body => JSON.dump(object), :headers => @my_headers)
    # response = self.class.post("/#{resource}", options)
    # case response.code
    #   when 201
    #     return response["result"]
    #   else
    #     raise "#{response["statusMessage"]} (Status code: #{response["statusCode"]})"
    # end
  end

  # Replaces the object with the given *id* with the data in *object*.
  # @param [String]   resource  Name of the resource
  # @param [String]   id  Id of the object that shall be updated
  # @param [Object]   object  Object that should be placed at the given id
  # @return nil
  def update(resource, id, object)
    LOG.debug "update: #{resource}"
    raise "Invalid resource" if not valid_resource?(resource)

    # options = { :body => JSON.dump(object) }
    # LOG.debug "Posting: #{options}"
    self.class.put(
      "#{@my_base_url}/#{resource}/#{id}",
      :body => JSON.dump(object), :headers => @my_headers)
    # response = self.class.put("/#{resource}/#{id}", options)
    # case response.code
    #   when 200
    #     return remove_init_object response["result"]
    #   else
    #     raise "#{response["statusMessage"]} (Status code: #{response["statusCode"]})"
    # end
  end

  # Get a single object of type resource, with the given id
  # @param [String] resource    Name of the resource
  # @param [String] id          Id of the object
  # @return [Hash] containing result, statusCode and statusMessage. Object for the given id.
  def get(resource, id)
    LOG.debug "get: #{resource}"
    raise "Invalid resource" if not valid_resource?(resource)

    self.class.get(
      "#{@my_base_url}/#{resource}/#{id}", 
      :headers => @my_headers)
    # response = self.class.get("/#{resource}/#{id}")
    # case response.code
    #   when 200
    #     return response["result"]
    #   else
    #     raise "#{response["statusMessage"]} (Status code: #{response["statusCode"]})"
    # end
  end

  # Deletes a single object of type resource, with the given id
  # @param [String] resource    Name of the resource
  # @param [String] id          Id of the object
  # @return [Hash] containing result, statusCode and statusMessage. Includes the id of the deleted object.
  def delete(resource, id)
    LOG.debug "delete: #{resource}"
    raise "Invalid resource" if not valid_resource?(resource)

    self.class.delete(
      "#{@my_base_url}/#{resource}/#{id}", 
      :headers => @my_headers)
  end

  # Get all objects of type resource
  # @param [String] resource    Name of the resource
  # @return [Hash] containing result, statusCode and statusMessage. Array of all objects in the given resource.
  def get_all(resource)
    LOG.debug "get_all: #{resource}"
    raise "Invalid resource" if not valid_resource?(resource)

    self.class.get(
      "#{@my_base_url}/#{resource}", 
      :headers => @my_headers)
    # response = self.class.get("/#{resource}")
    # case response.code
    #   when 200
    #     return response["result"]
    #   else
    #     raise "#{response["statusMessage"]} (Status code: #{response["statusCode"]})"
    # end
  end

  # Search for objects of the given resource type, that match the query_string
  # @param [String] resource        Name of the resource
  # @param [String] query_string    Query to search for within this resource. Syntax as defined in {QUERY-SYNTAX}
  # @return [Hash] containing result, statusCode and statusMessage. Array of objects that matched the query_string.
  def search(resource, query_string)
    LOG.debug "search: #{resource}"
    raise "Invalid resource" if not valid_resource?(resource)

    # options = { :query => {:q => query_string} }
    # LOG.debug "Searching for: #{options}"
    self.class.get(
      "#{@my_base_url}/#{resource}", 
      :query => {:q => query_string}, :headers => @my_headers)
    # response = self.class.get("/#{resource}", options)
    # case response.code
    #   when 200
    #     return remove_init_object response["result"]
    #   else
    #     raise "#{response["statusMessage"]} (Status code: #{response["statusCode"]})"
    # end
  end

  private

  # Checks if the given resource is known within this API Client
  def valid_resource?(resource)
     @resources.include? resource
  end

end
