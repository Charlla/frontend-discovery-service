output "project_store_name" {
  value = aws_dynamodb_table.project_store.name
}

output "frontend_store_name" {
  value = aws_dynamodb_table.frontend_store.name
}

output "version_store_name" {
  value = aws_dynamodb_table.version_store.name
}

output "deployment_store_name" {
  value = aws_dynamodb_table.deployment_store.name
}

output "frontend_store_arn" {
  value = aws_dynamodb_table.frontend_store.arn
}

output "project_store_arn" {
  value = aws_dynamodb_table.project_store.arn
}

output "consumer_store_arn" {
  value = aws_dynamodb_table.consumer_store.arn
}

output "version_store_arn" {
  value = aws_dynamodb_table.version_store.arn
}

output "deployment_store_arn" {
  value = aws_dynamodb_table.deployment_store.arn
}

output "consumer_store_name" {
  value = aws_dynamodb_table.consumer_store.name
}

output "dynamodb_stream_arn" {
  value = aws_dynamodb_table.project_store.stream_arn
} 