resource "aws_ecr_repository" "repository" {
  name                 = "${var.project}-${var.environment}-ecr"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "${var.project}-${var.environment}-ecr"
    Project     = var.project
    Environment = var.environment
  }
}