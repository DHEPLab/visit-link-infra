variable "env" {
  description = "enviroment"
  type        = string
  validation {
    condition     = can(regex("^dev|prod$", var.env))
    error_message = "Deploy envirment must follow regex(\"^dev|prod$\") rule."
  }
}

variable "project_name" {
  description = "project name"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "alb_subnet_ids" {
  description = "subnet ids of alb"
  type        = list(string)
}

variable "ecs_subnet_ids" {
  description = "subnet ids of ecs"
  type        = list(string)
}

variable "service_image_uri" {
  description = "service image uri"
  type        = string
}

variable "admin_web_image_uri" {
  description = "web admin image uri"
  type        = string
}

variable "region" {
  type = string
}

variable "database_url" {
  type = string
}
