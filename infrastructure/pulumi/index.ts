import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as cloudflare from "@pulumi/cloudflare";
import * as docker from "@pulumi/docker";

// =============================================================================
// Configuration
// =============================================================================

const config = new pulumi.Config();
const environment = config.require("environment");
const region = config.get("region") || "us-east-1";

const projectName = `aurasync-${environment}`;

// =============================================================================
// AWS Infrastructure
// =============================================================================

// VPC
const vpc = new aws.ec2.Vpc(`${projectName}-vpc`, {
  cidrBlock: "10.0.0.0/16",
  enableDnsHostnames: true,
  enableDnsSupport: true,
  tags: {
    Name: projectName,
    Environment: environment,
  },
});

// Subnets
const publicSubnet = new aws.ec2.Subnet(`${projectName}-public`, {
  vpcId: vpc.id,
  cidrBlock: "10.0.1.0/24",
  availabilityZone: `${region}a`,
  mapPublicIpOnLaunch: true,
  tags: {
    Name: `${projectName}-public`,
  },
});

const privateSubnet = new aws.ec2.Subnet(`${projectName}-private`, {
  vpcId: vpc.id,
  cidrBlock: "10.0.2.0/24",
  availabilityZone: `${region}b`,
  tags: {
    Name: `${projectName}-private`,
  },
});

// Internet Gateway
const internetGateway = new aws.ec2.InternetGateway(`${projectName}-igw`, {
  vpcId: vpc.id,
  tags: {
    Name: `${projectName}-igw`,
  },
});

// Route Table
const publicRouteTable = new aws.ec2.RouteTable(`${projectName}-public-rt`, {
  vpcId: vpc.id,
  routes: [
    {
      cidrBlock: "0.0.0.0/0",
      gatewayId: internetGateway.id,
    },
  ],
  tags: {
    Name: `${projectName}-public-rt`,
  },
});

const publicRouteTableAssociation = new aws.ec2.RouteTableAssociation(`${projectName}-public-rta`, {
  subnetId: publicSubnet.id,
  routeTableId: publicRouteTable.id,
});

// Security Group
const securityGroup = new aws.ec2.SecurityGroup(`${projectName}-sg`, {
  vpcId: vpc.id,
  description: "Security group for AuraSync services",
  ingress: [
    {
      fromPort: 80,
      toPort: 80,
      protocol: "tcp",
      cidrBlocks: ["0.0.0.0/0"],
      description: "HTTP",
    },
    {
      fromPort: 443,
      toPort: 443,
      protocol: "tcp",
      cidrBlocks: ["0.0.0.0/0"],
      description: "HTTPS",
    },
    {
      fromPort: 8080,
      toPort: 8082,
      protocol: "tcp",
      cidrBlocks: ["0.0.0.0/0"],
      description: "API ports",
    },
    {
      fromPort: 1883,
      toPort: 1883,
      protocol: "tcp",
      cidrBlocks: ["0.0.0.0/0"],
      description: "MQTT",
    },
  ],
  egress: [
    {
      fromPort: 0,
      toPort: 0,
      protocol: "-1",
      cidrBlocks: ["0.0.0.0/0"],
    },
  ],
  tags: {
    Name: `${projectName}-sg`,
  },
});

// =============================================================================
// ECS Cluster
// =============================================================================

const cluster = new aws.ecs.Cluster(`${projectName}-cluster`, {
  settings: [
    {
      name: "containerInsights",
      value: "enabled",
    },
  ],
  tags: {
    Name: projectName,
  },
});

// Task Definitions
const apiGatewayTaskDef = new aws.ecs.TaskDefinition(`${projectName}-api-gateway`, {
  family: `${projectName}-api-gateway`,
  networkMode: "awsvpc",
  requiresCompatibilities: ["FARGATE"],
  cpu: "256",
  memory: "512",
  executionRoleArn: ecsRole.arn,
  taskRoleArn: ecsRole.arn,
  containerDefinitions: JSON.stringify([
    {
      name: "api-gateway",
      image: `${aws.accountId.get()}.dkr.ecr.${region}.amazonaws.com/${projectName}-api-gateway:latest`,
      portMappings: [
        {
          containerPort: 8082,
          protocol: "tcp",
        },
      ],
      environment: [
        {
          name: "PORT",
          value: "8082",
        },
        {
          name: "REDIS_ADDR",
          value: redisEndpoint,
        },
      ],
      logConfiguration: {
        logDriver: "awslogs",
        options: {
          "awslogs-group": `/ecs/${projectName}-api-gateway`,
          "awslogs-region": region,
          "awslogs-stream-prefix": "ecs",
        },
      },
    },
  ]),
  tags: {
    Name: `${projectName}-api-gateway`,
  },
});

// =============================================================================
// Outputs
// =============================================================================

export const vpcId = vpc.id;
export const publicSubnetId = publicSubnet.id;
export const privateSubnetId = privateSubnet.id;
export const clusterId = cluster.id;
export const securityGroupId = securityGroup.id;
