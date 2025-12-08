resource "aws_ecr_repository" "repository" {
  name                 = "${var.project}-${var.environment}"
  image_tag_mutability = "MUTABLE"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}