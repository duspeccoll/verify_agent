ArchivesSpace::Application.routes.draw do
  match('/agents/people/:id/verify' => 'verify_agent#verify', :via => [:get])
  match('/agents/corporate_entities/:id/verify' => 'verify_agent#verify', :via => [:get])
  match('/agents/families/:id/verify' => 'verify_agent#verify', :via => [:get])
end
