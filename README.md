ApitraryClient: A Ruby client for your apitrary API
====================================

**Homepage**:     [http://apitrary.com](http://apitrary.com)

**Author**:       apitrary

**Copyright**:    2012

**License**:      MIT License


Synopsis
----------------

With ApitraryClient for ruby you can easily communicate with your apitrary API.


Installation
----------------

Add the following gem to your Gemfile

    gem "apitrary-client", :git => "git@github.com:apitrary/ruby-client.git"


Usage
----------------

Generate a new client, providing the URL of your API and the API key.

    client = ApitraryClient.new( "http://YOUR_API_ID.api.apitrary.net", "YOUR_API_KEY" )

Assuming your have created an entity **person** in your API, you would use the following calls to work with
this entity:

### Add object

    response = client.add( "person", {"firstnamename" => "John", "lastname" => "Doe"} )

### Update object

    client.update( "person", "ID_OF_OBJECT", {"firstnamename" => "Peter", "lastname" => "Smith"} )

### Get object

    response = client.get( "person", "ID_OF_OBJECT" )

### Delete object

    response = client.delete( "person", "ID_OF_OBJECT" )

### Get all objects

    response = client.get_all( "person" )

### Search for objects

    response = client.search( "person", "lastname:Doe" )


Contributing
----------------

### Found a bug?

Please [file an issue](https://github.com/apitrary/ruby-client/issues).

### Running the tests

    rake

### Building the gem

	rake build

### Installing the gem

	rake install


CHANGELOG
----------------

0.4.0

- documentation cleanup
- release on github

0.3.0

- moved api-key to header as X-Api-Key
- set Accept Header application/json

