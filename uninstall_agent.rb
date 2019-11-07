Backups::Plugin.hook do
  # r1soft doesn't support uninstalling the object
  def call(virtual_server); end
end
