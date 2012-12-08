#!/usr/bin/env ruby
require "rubygems"
require "bundler"
Bundler.setup
Bundler.require(:default, :test)

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/apitrary-client.rb'))

# setup FakeWeb / all HTTP calls from test will run against that
FakeWeb.allow_net_connect = false

HOSTNAME = "localhost"
FULL_RESOURCES_PATH = "http://#{HOSTNAME}/aaaaaaaa/v1"
AUTH = "api_key=RUBY_CLIENT_TEST_KEY"

# status
FakeWeb.register_uri(
    :get, "http://localhost/status?#{AUTH}",
    :body => JSON[
        {
            "project" => {
              "name" => "PyGenAPI", "copyright" => "2012 apitrary.com", "support" => "http://apitrary.com/support",
              "contact" => "support@apitrary.com", "version" => "0.2.0", "company" => "apitrary"
            },
            "db_status" => "OK",
            "api" => {
              "base_url" => "/aaaaaaaa/v1", "schema_url" => "/aaaaaaaa/v1/schema", "api_id" => "aaaaaaaa", "api_version" => 1
            }
        }
    ],
    :content_type => "application/json"
)

# info
FakeWeb.register_uri(
    :get, "http://localhost/info?#{AUTH}",
    :body => JSON[ {"name" => "GenAPI v1", "copyright" => "2012 apitrary.com"} ],
    :content_type => "application/json"
)

# schema
FakeWeb.register_uri(
    :get, "#{FULL_RESOURCES_PATH}/schema?#{AUTH}",
    :body => JSON[ { "schema" => ["images"] } ],
    :content_type => "application/json"
)

# add
FakeWeb.register_uri(
    :post, "#{FULL_RESOURCES_PATH}/images?#{AUTH}",
    :body => JSON[ {"_id" => "123"} ],
    :content_type => "application/json"
)

# get
FakeWeb.register_uri(
    :get, "#{FULL_RESOURCES_PATH}/images/SOME_HASH?#{AUTH}",
    :body => JSON[
        {
        "result" => {
          "_data" => {
            "firstName" => "Peter", "_createdAt" => 1346858290.646908, "lastName" => "Watson", "age" => 37,
            "_updatedAt" => 1346858318.801598, "address" => "Celle"
          },
          "_id" => "e745d7f4f76c11e1b29a00163eda889a"},
          "statusMessage" => "OK",
          "statusCode" => 200
        }
    ],
    :content_type => "application/json"
)

# get_all
FakeWeb.register_uri(
    :get, "#{FULL_RESOURCES_PATH}/images?#{AUTH}",
    :body => JSON[ {"result" => [{"_id" => "HASH_1"},{"_id" => "HASH_2"}, {"_id" => "HASH_3"}, {"_id" => "HASH_4"}] } ],
    :content_type => "application/json"
)

# update
FakeWeb.register_uri(
    :put, "#{FULL_RESOURCES_PATH}/images/SOME_HASH?#{AUTH}",
    :body => JSON[ {"_id" => "123"} ],
    :content_type => "application/json"
)

# delete
FakeWeb.register_uri(
    :delete, "#{FULL_RESOURCES_PATH}/images/SOME_HASH?#{AUTH}",
    :body => JSON[ {"deleted" => "SOME_HASH"} ],
    :content_type => "application/json"
)

# search
FakeWeb.register_uri(
    :get, "#{FULL_RESOURCES_PATH}/images?q=data%3Avalue&#{AUTH}",
    :body => JSON[ {"result" => [{"_id" => "HASH_1"},{"_id" => "HASH_2"}, {"_id" => "HASH_3"}] } ],
    :content_type => "application/json"
)

# Exception for get
FakeWeb.register_uri(
    :get, "#{FULL_RESOURCES_PATH}/images/NON_EXISTENT_ID?#{AUTH}",
    :body => JSON[ {"status" => 404} ],
    :status => [404, "Not Found"],
    :content_type => "application/json"
)

describe ApitraryClient do
  LONG_SLEEP = 3

  before(:each) do
    @client = ApitraryClient.new("localhost","RUBY_CLIENT_TEST_KEY")
  end

  describe "Monitoring calls" do

    it "check API status" do
      response =  @client.status
      response.should_not == nil
      response["db_status"].should == "OK"
    end

    it "check API info" do
      response =  @client.info
      response.should_not == nil
      response.should be_a_kind_of(Hash)
    end

    it "check API schema" do
      response =  @client.schema
      response.should_not == nil
      response.should be_a_kind_of(Hash)
      response.keys.should include("schema")
    end

  end

  describe "CRUD" do

    it "add" do
      response = @client.add( "images", {"key" => "some value"} )
      response.should_not == nil
      response.should be_a_kind_of(Hash)
      response.keys.should include("_id")
    end

    it "update" do
      response = @client.update( "images", "SOME_HASH", {"key" => "some value"} )
      response.should_not == nil
      response.should be_a_kind_of(Hash)
      response.keys.should include("_id")
    end

    it "get" do
      response = @client.get( "images", "SOME_HASH" )
      response.should_not == nil
      response.should be_a_kind_of(Hash)
      response.keys.should include("result")
      response.keys.size.should be >= 2
    end

    it "delete" do
      response = @client.delete( "images", "SOME_HASH" )
      response.should_not == nil
      response.should be_a_kind_of(Hash)
      response.keys.should include("deleted")
      response["deleted"].should == "SOME_HASH"
    end

    it "get_all" do
      response = @client.get_all( "images" )
      response.should_not == nil
      response.should be_a_kind_of(Hash)
      response.keys.should include("result")
      response["result"].size.should == 4
    end

    it "search" do
      response = @client.search( "images", "data:value")
      response.should_not == nil
      response.should be_a_kind_of(Hash)
      response.keys.should include("result")
      response["result"].size.should == 3
    end

  end


  describe "Exceptions" do

    it "non existent ID" do
      response = @client.get( "images", "NON_EXISTENT_ID")
      response.should_not == nil
      response["status"] == 404
    end

    it "non existent resource" do
      lambda { @client.get( "resource_that_does_not_exist", "NON_EXISTENT_ID") }.should raise_error
    end

    #TODO other exceptions and error codes

    #TODO request for a resource that the client does not even knows

  end

end