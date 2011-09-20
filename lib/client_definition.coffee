# Defines a client read from the client configuration file.
class ClientDefinition

  constructor: (json) ->
    throw "Missing ID for client #{json}" unless json.id?
    @id = json.id

    throw "Missing name for client #{json}" unless json.name?
    @name = json.name

    throw "Missing contacts for client #{json}" unless json.contacts? && json.contacts.length > 0
    @contacts = []
    for contact in json.contacts
      @contacts.push new ContactDefinition contact

# Defines a contact for a client.
class ContactDefinition

  constructor: (json) ->
    throw "Missing name for contact #{json}" unless json.name?
    @name = json.name

    throw "Missing e-mail address for contact #{json}" unless json.email?
    @email = json.email

module.exports = ClientDefinition
