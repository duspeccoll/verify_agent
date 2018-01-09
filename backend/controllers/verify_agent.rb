class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/agents/people/:id/verify')
    .description("Verify that the Authority ID for the authorized name of an Agent resolves to an authority record")
    .params(["id", Integer, "The ID of the Person agent"])
    .permissions([])
    .returns([200, "OK"]) \
  do
    agent = resolve_references(AgentPerson.to_jsonmodel(AgentPerson.get_or_die(params[:id])), params[:resolve])
    json = verify_record(agent)

    json_response(json)
  end

  Endpoint.get('/agents/corporate_entities/:id/verify')
    .description("Verify that the Authority ID for the authorized name of an Agent resolves to an authority record")
    .params(["id", Integer, "The ID of the Corporate agent"])
    .permissions([])
    .returns([200, "OK"]) \
  do
    agent = resolve_references(AgentCorporateEntity.to_jsonmodel(AgentCorporateEntity.get_or_die(params[:id])), params[:resolve])
    json = verify_record(agent)

    json_response(json)
  end

  Endpoint.get('/agents/families/:id/verify')
    .description("Verify that the Authority ID for the authorized name of an Agent resolves to an authority record")
    .params(["id", Integer, "The ID of the Family agent"])
    .permissions([])
    .returns([200, "OK"]) \
  do
    agent = resolve_references(AgentFamily.to_jsonmodel(AgentFamily.get_or_die(params[:id])), params[:resolve])
    json = verify_record(agent)

    json_response(json)
  end

  private

  def query_uri(s)
    # VIAF requires a trailing forward slash for some reason
    s << "/" if s.start_with?("http://viaf.org/viaf")

    resp = Net::HTTP.get_response(URI(s))
    case resp
    when Net::HTTPSuccess then
      "OK"
    when Net::HTTPRedirection then
      s = resp['location']
      query_uri(s)
    when Net::HTTPNotFound then
      "No record with this Authority ID found"
    else
      "Error: #{s} (#{resp.code})"
    end
  end

  def verify_record(agent)
    locals = ['ingest', 'local', 'prov']
    uri_prefix = {
      'naf' => "http://id.loc.gov/authorities/names/",
      'ulan' => "http://vocab.getty.edu/ulan/",
      'lcsh' => "http://id.loc.gov/authorities/subjects/",
      'viaf' => "http://viaf.org/viaf/"
    }
    json = {}

    agent['names'].each do |name|
      if name['authorized']
        id = name['authority_id']
        json['uri'] = "#{uri_prefix[name['source']]}#{id}"
        if locals.include?(name['source'])
          json['status'] = "OK"
        else
          if ASUtils.blank?(id)
            json['status'] = "Authority ID must be present if a non-local source is declared"
          else
            begin
              if uri_prefix[name['source']].nil?
                json['status'] = "No URI prefix found for #{name['source']}"
              else
                json['status'] = query_uri(json['uri'])
              end
            rescue StandardError => e
              json['status'] = e
            end
          end
        end
      end
    end

    return json
  end
end
