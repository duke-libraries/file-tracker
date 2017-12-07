UPDATE tracked_files tf
INNER JOIN tracked_directories td
ON tf.path LIKE CONCAT(td.path, '/%')
SET tf.tracked_directory_id = td.id, 
    tf.path = SUBSTRING(tf.path, length(td.path)+2);
