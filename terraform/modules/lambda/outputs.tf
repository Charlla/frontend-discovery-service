output "admin_lambda_invoke_arn" {
  description = "Invoke ARN of the admin Lambda function"
  value       = aws_lambda_function.admin_api.invoke_arn
}

output "consumer_lambda_invoke_arn" {
  description = "Invoke ARN of the consumer Lambda function"
  value       = aws_lambda_function.consumer_api.invoke_arn
}

output "stream_processor_arn" {
  description = "ARN of the stream processor Lambda function"
  value       = aws_lambda_function.stream_processor.arn
}

output "admin_lambda_function_name" {
  description = "Name of the admin Lambda function"
  value       = aws_lambda_function.admin_api.function_name
}

output "consumer_lambda_function_name" {
  description = "Name of the consumer Lambda function"
  value       = aws_lambda_function.consumer_api.function_name
}

output "stream_processor_function_name" {
  description = "Name of the stream processor Lambda function"
  value       = aws_lambda_function.stream_processor.function_name
} 