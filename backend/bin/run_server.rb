require_relative '../app/server'
users = UserCollection.new
domain_model = DomainModel.new(users: users)
server = Server.new
server.start(domain_model, foreground: true, port: 8888)
