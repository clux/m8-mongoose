# Browser Mongoose via modul8
m8-mongoose is a [modul8](https://github.com/clux/modul8) plugin that aims to partially port mongoose logic to the client.

A web application using mongodb on its backend and using mongoose as an ORM layer ends up defining a lot of validation logic on the server.
Logic that should be reused on the client. This plugin will export sanitized versions of your explicitly exported mongoose models, along with helpers
to utilize this data in a helpful way.

## Pre-Requisites
m&m&m:

- mongodb
- mongoose
- modul8

Willingness to perform an extra function call when defining your mongoose modules.

## Usage
Install with

    $ npm install m8-mongoose

then require the register function, and register a model with it

````javascript
var Schema = require('mongoose').Schema;
var toBrowser = require('m8-mongoose').register;

User = new Schema(toBrowser('user', {
  name : String
  pass : {type: String, private: true}
}));
````

The output Schema instance is mongoose compatible (toBrowser removes extra attributes like `private` above).

On deployment, the plugin will pass back the serialized version of what was passed in above directly to modul8

````javascript
var modul8 = require('modul8')
var MongoosePlugin = require('m8-mongoose').Plugin;
modul8('./client/app.js')
  .use(new MongoosePlugin())
  .compile('./out.js');
````

Optionally, an object can be specified as a second argument to the constructor to tweak the module's behavior. It's keys are:

- `domain` - Domain to export helper code to (defaults to 'mongoose')
- `key` - Key on the data domain to export the sanitized models to (defaults to 'models')


## Behavior
Calls to `register()` serializes the model to the plugins 'runtime' directory, whereas `MongoosePlugin` will read these for modul8.
Code to help auto generate certain form code and validation logic is (soon) included on the `mongoose` domain, and will be bundled with the output source if required
by the application.

## Extensions
You can extend the classical mongoose object with certain unused attributes. These work as follows:

- `private` - if true, it this key will not be sent to the client
- `label` - if set, it will be used by formGenerator to construct standard text inputs
- `labels` - if set to array, it will be used by formGenerator to construct a select input

These attributes will be removed before passing the object back to mongoose's Schema constructor.

## License
MIT Licensed - See LICENSE file for details
