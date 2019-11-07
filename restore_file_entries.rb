# frozen_string_literal: true

Backups::Plugin.hook helpers: %i[recovery_points_client_helper task_history_client_helper task_helper] do
  BASE_PATH = '/'

  def call(recovery_point, virtual_server, paths)
    wait_for_task!(restore_file_paths(recovery_point.metadata[:id], virtual_server.metadata[:disk_safe_id], paths))
  end

  private

  def restore_file_paths(recovery_point_id, disk_safe_id, paths)
    recovery_points_client.call(:do_file_restore, message: {
                                  recoveryPoint: {
                                    recoveryPointID: recovery_point_id,
                                    diskSafeID: disk_safe_id
                                  },
                                  fileRestoreOptions: {
                                    overwriteExistingFiles: true,
                                    basePath: BASE_PATH,
                                    fileNames: cleaned_paths(paths)
                                  }
                                }).body[:do_file_restore_response][:return][:id]
  end

  def cleaned_paths(paths)
    paths.map { |p| p.sub(/^#{BASE_PATH}/, '') }
  end
end
