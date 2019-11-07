Backups::Plugin.hook do
  def call(local_recovery_point, remote_recovery_point)
    local_recovery_point.metadata[:id] == remote_recovery_point.metadata[:id] ? success : error
  end
end
