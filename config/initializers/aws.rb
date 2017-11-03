Aws.config.update(
  region: "use-east-2",
  credentials: Aws::Credentials.new(ENV["HELPQA_AWS_ID"], ENV["HELPQA_AWS_ACCESS"])
)

S3_BUCKET = Aws::S3::Resource.new.bucket("help-qa")
