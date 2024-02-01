output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.task.arn
}

output "ecs_task_definition_family" {
  description = "The family of the ECS task definition"
  value       = aws_ecs_task_definition.task.family
}

output "ecs_task_definition" {
  description = "The entire ECS task definition"
  value       = aws_ecs_task_definition.task
}

output "ecs_service" {
  description = "The entire ECS service definition"
  value       = aws_ecs_service.service
}

