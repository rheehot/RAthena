context("Athena Metadata")

# NOTE System variable format returned for Unit tests:
# Sys.getenv("rathena_arn"): "arn:aws:sts::123456789012:assumed-role/role_name/role_session_name"
# Sys.getenv("rathena_s3_query"): "s3://path/to/query/bucket/"
# Sys.getenv("rathena_s3_tbl"): "s3://path/to/bucket/"

df_col_info <- data.frame(field_name = c("w","x","y", "z", "timestamp"),
                          type = c("timestamp", "integer", "varchar", "boolean", "varchar"), stringsAsFactors = F)

con_info = c("profile_name", "s3_staging","dbms.name","work_group", "poll_interval","encryption_option","kms_key","expiration", "keyboard_interrupt","region_name", "boto3", "RAthena")
col_info_exp = c("w","x","y", "z", "timestamp")

test_that("Returning meta data",{
  skip_if_no_boto()
  skip_if_no_env()
  # Test connection is using AWS CLI to set profile_name 
  con <- dbConnect(RAthena::athena(),
                   s3_staging_dir = Sys.getenv("rathena_s3_query"))
  
  res = dbExecute(con, "select * from test_df")
  res_out = dbHasCompleted(res)
  res_info = dbGetInfo(res)
  res_stat = dbStatistics(res)
  column_info1 = dbColumnInfo(res)
  column_info2 = dbListFields(con, "test_df")
  con_info_exp = names(dbGetInfo(con))
  list_tbl1 = any(grepl("test_df", dbListTables(con, "default")))
  list_tbl2 = nrow(dbGetTables(con, "default")[TableName == "test_df"]) == 1
  partition = grepl("timestamp", dbGetPartition(con, "test_df")[[1]])
  db_show_ddl = gsub(", \n  'transient_lastDdlTime'.*",")", dbShow(con, "test_df"))
  db_info = dbGetInfo(con)
  dbClearResult(res)
  dbDisconnect(con)
  
  expect_equal(column_info1, df_col_info)
  expect_equal(column_info2, col_info_exp)
  expect_equal(con_info, con_info_exp)
  expect_true(list_tbl1)
  expect_true(list_tbl2)
  expect_true(partition)
  expect_equal(db_show_ddl, show_ddl)
  expect_warning(RAthena:::time_check(Sys.time() + 10))
  expect_error(RAthena:::pkg_method("made_up", "made_up_pkg"))
  expect_false(RAthena:::is.s3_uri(NULL))
  expect_true(is.list(db_info))
  expect_error(dbGetInfo(con))
  expect_true(res_out)
  expect_equal(names(res_info), c("QueryExecutionId", "NextToken"))
  expect_true(is.list(res_stat))
})