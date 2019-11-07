Backups::Plugin.helper do
  def disk_safe_client
    @disk_safe_client ||= Savon.client(wsdl: "#{primary_host}/DiskSafe?wsdl",
                                       basic_auth: [username, password])
  end
end
