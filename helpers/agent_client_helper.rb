Backups::Plugin.helper do
  def agent_client
    @agent_client ||= Savon.client(wsdl: "#{primary_host}/Agent?wsdl",
                                   basic_auth: [username, password])
  end
end
