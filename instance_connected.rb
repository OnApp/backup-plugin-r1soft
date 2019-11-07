Backups::Plugin.hook helpers: :agent_client_helper do
  def call(virtual_server)
    agent_client.call(:get_agent_by_id, message: { id: virtual_server.metadata['agent_id'] })

    success
  rescue Savon::SOAPFault # if we are here it means that instance doesn't exists on r1soft
    error
  end
end
