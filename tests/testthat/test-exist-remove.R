context("Exist/Remove")

# NOTE System variable format returned for Unit tests:
# Sys.getenv("rathena_arn"): "arn:aws:sts::123456789012:assumed-role/role_name/role_session_name"
# Sys.getenv("rathena_s3_query"): "s3://path/to/query/bucket/"
# Sys.getenv("rathena_s3_tbl"): "s3://path/to/bucket/"

s3.location <- paste0(Sys.getenv("rathena_s3_tbl"),"removable_table/")

test_that("Check a table exist and remove table",{
  skip_if_no_boto()
  skip_if_no_env()
  # Test connection is using AWS CLI to set profile_name 
  con <- dbConnect(athena(),
                   s3_staging_dir = Sys.getenv("rathena_s3_query"))
  
  table_exist1 <- dbExistsTable(con, "removable_table")
  
  df <- data.frame(x = 1:10, y = letters[1:10], stringsAsFactors = F)
  
  dbWriteTable(con, "removable_table", df, s3.location = s3.location)
  
  table_exist2 <- dbExistsTable(con, "removable_table")
  
  dbRemoveTable(con, "removable_table", confirm = T)
  
  table_exist3 <- dbExistsTable(con, "removable_table")  
  
  expect_equal(table_exist1, FALSE)
  expect_equal(table_exist2, TRUE)
  expect_equal(table_exist3, FALSE)
})
