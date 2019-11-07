# frozen_string_literal: true

Backups::Plugin.hook helpers: :recovery_points_client_helper do
  SEPARATOR = '/'

  def call(recovery_point, virtual_server, root_dir)
    root_dir ||= SEPARATOR

    file_entries(recovery_point.metadata[:id], virtual_server.metadata[:disk_safe_id], root_dir).map do |f|
      path = [''].tap do |p|
        p << root_dir.sub(/^#{SEPARATOR}/, '') unless root_dir == SEPARATOR
        p << f[:file_path]
      end.join('/')

      build_file_entry(path: path,
                       file_name: f[:file_path],
                       dir: f[:is_directory],
                       size: f[:is_directory] ? nil : f[:file_size].to_i,
                       last_modified: Time.at(f[:modify_time].to_i / 1000))
    end
  rescue Savon::SOAPFault # Null or empty object received
    []
  end

  private

  def file_entries(recovery_point_id, disk_safe_id, root_dir)
    res = recovery_points_client.call(:get_multiple_file_entry_information, message: {
                                        recoveryPoint: {
                                          recoveryPointID: recovery_point_id,
                                          diskSafeID: disk_safe_id
                                        },
                                        fileSystemPath: root_dir,
                                        directoryEntries: directories(recovery_point_id, disk_safe_id, root_dir)
                                      }).body[:get_multiple_file_entry_information_response][:return]

    res.is_a?(Array) ? res : [res]
  end

  def directories(recovery_point_id, disk_safe_id, root_dir)
    res = recovery_points_client.call(:get_directory_entries, message: {
                                        recoveryPoint: {
                                          recoveryPointID: recovery_point_id,
                                          diskSafeID: disk_safe_id
                                        },
                                        fileSystemPath: root_dir
                                      }).body[:get_directory_entries_response][:return]

    res.is_a?(Array) ? res : [res]
  end
end
