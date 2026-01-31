# RDS PostgreSQL Configuration (Optional - controlled by enable_rds variable)

# Security group for RDS
resource "aws_security_group" "rds" {
  count = var.enable_rds ? 1 : 0

  name_prefix = "${var.cluster_name}-rds"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-rds-sg"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "rds" {
  count = var.enable_rds ? 1 : 0

  name       = "${var.cluster_name}-db-subnet"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.cluster_name}-db-subnet-group"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  count = var.enable_rds ? 1 : 0

  identifier     = "${var.cluster_name}-postgres"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = local.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]

  # High Availability
  multi_az               = true
  publicly_accessible    = false
  
  # Backup configuration
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  # Performance and monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 60
  monitoring_role_arn            = aws_iam_role.rds_monitoring[0].arn
  performance_insights_enabled    = true

  # Deletion protection
  deletion_protection = false  # Set to true in production
  skip_final_snapshot = true   # Set to false in production

  tags = {
    Name = "${var.cluster_name}-postgres"
  }
}

# IAM role for RDS enhanced monitoring
resource "aws_iam_role" "rds_monitoring" {
  count = var.enable_rds ? 1 : 0

  name = "${var.cluster_name}-rds-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.enable_rds ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Store DB credentials in Kubernetes secret
resource "kubernetes_secret" "db_credentials" {
  count = var.enable_rds ? 1 : 0

  metadata {
    name      = "db-credentials"
    namespace = "default"
  }

  data = {
    host     = aws_db_instance.postgres[0].address
    port     = tostring(aws_db_instance.postgres[0].port)
    database = var.db_name
    username = var.db_username
    password = local.db_password
    url      = "postgresql://${var.db_username}:${local.db_password}@${aws_db_instance.postgres[0].address}:${aws_db_instance.postgres[0].port}/${var.db_name}"
  }

  type = "Opaque"

  depends_on = [module.eks, aws_db_instance.postgres]
}
