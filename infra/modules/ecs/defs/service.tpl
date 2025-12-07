[
    {
        "name": "receipt-api",
        "image": "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${ecr_repository_name}:latest",
        "cpu": 0,
        "links": [],
        "portMappings": [
            {
                "containerPort": 8000,
                "hostPort": 8000,
                "protocol": "tcp"
            }
        ],
        "essential": true,
        "environment": [
            {
                "name": "PORT",
                "value": "8000"
            },
            {
                "name": "LOG_LEVEL",
                "value": "INFO"
            },
            {
                "name": "DATABASE_HOST",
                "value": "${rds_address}"
            },
            {
                "name": "DATABASE_PORT",
                "value": "${rds_port}"
            },
            {
                "name": "DATABASE_USER",
                "value": "${rds_user}"
            },
        ],
        "mountPoints": [],
        "volumesFrom": [],
        "linuxParameters": {
            "capabilities": {}
        },
        "secrets": [
            {
                "name": "DATABASE_PASSWORD",
                "valueFrom": "${secretsmanager_arn}:password::"
            }
        ],
        "privileged": false,
        "readonlyRootFilesystem": true,
        "dnsServers": [],
        "dnsSearchDomains": [],
        "dockerSecurityOptions": ["no-new-privileges"],
        "pseudoTerminal": false,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-create-group": "true",
                "awslogs-group": "${project_name}-${environment}-app-log-group",
                "awslogs-region": "${aws_region}",
                "awslogs-stream-prefix": "${environment}-app"
            }
        },
        "healthCheck": {
            "command": [
                "CMD-SHELL",
                "curl -s -f http://localhost:8000/health || exit 1"
            ],
            "interval": 30,
            "timeout": 3,
            "retries": 3,
            "startPeriod": 10
        }
    }
]