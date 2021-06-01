# encoding: utf-8

class Sherlock::Controllers::Watson < Sherlock::Sinatra::BaseController

  # Handle ParserErrors from the snapshot parser and present them properly to
  # any connecting agent.
  error Sherlock::Errors::ParserError do
    status(422) # Unprocessable entity.
    env['sinatra.error'].message
  end
  
  post '/snapshot' do
    parser = Sherlock::SnapshotParser.new(request.body.read.to_s)
    parser.persist!
    parser.snapshot.id.to_s
  end

end
