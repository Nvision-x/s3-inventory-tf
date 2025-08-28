output "inventory_configurations" {
  description = "Map of bucket names to their inventory configuration details"
  value = {
    for bucket_name, config in aws_s3_bucket_inventory.inventory_config :
    bucket_name => {
      inventory_id = config.name
      destination  = config.destination[0].bucket[0].bucket_arn
      prefix      = config.destination[0].bucket[0].prefix
      frequency   = config.schedule[0].frequency
      enabled     = config.enabled
      region      = var.region
    }
  }
}