update tracked_files tf
inner join tracked_directories td
on tf.tracked_directory_id = td.id
set tf.path = substring(tf.path, length(td.path)+2)
where tf.path like '/%';
