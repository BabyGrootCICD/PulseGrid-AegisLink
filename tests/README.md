# Robot Framework Test Suites

## Overview

This directory contains Robot Framework test suites for the PulseGrid-AegisLink (AuraSync) platform.

## Structure

```
tests/
├── resources/
│   └── common.robot          # Common keywords and variables
├── suites/
│   ├── api/
│   │   └── health_check.robot    # API endpoint tests
│   ├── integration/
│   │   └── service_integration.robot  # Service integration tests
│   └── e2e/
│       └── user_journey.robot    # End-to-end user journey tests
└── requirements.txt          # Python dependencies
```

## Test Suites

### API Tests (`tests/suites/api/`)

Tests for individual API endpoints:
- Health check
- User registration
- User login
- Room creation
- Room joining
- Age verification
- Withdrawals
- Validation errors

### Integration Tests (`tests/suites/integration/`)

Tests for service integration:
- Service health checks
- Database connectivity (PostgreSQL, MongoDB, Redis)
- User registration and login flow
- Room creation and joining flow
- Age verification flow
- Withdrawal flow
- IoT device command flow

### E2E Tests (`tests/suites/e2e/`)

End-to-end browser tests:
- Home page loading
- Navigation links
- Age verification modal
- Room listing
- Room creation
- Counseling booking
- Wallet connection
- Withdrawal panel
- Error handling (404, network errors)
- Responsive design (mobile, tablet)
- Form validation

## Running Tests

### Prerequisites

```bash
# Install Python dependencies
pip install -r tests/requirements.txt

# Install Robot Framework
pip install robotframework

# For E2E tests, install ChromeDriver
pip install webdrivermanager
webdrivermanager chrome
```

### Running All Tests

```bash
robot tests/
```

### Running Specific Suites

```bash
# API tests only
robot tests/suites/api/

# Integration tests only
robot tests/suites/integration/

# E2E tests only
robot tests/suites/e2e/
```

### Running Specific Test Cases

```bash
# Run a specific test case
robot --test "Health Check" tests/

# Run tests by tag
robot --include api tests/
```

## Test Tags

Tests are tagged for selective execution:
- `api` - API endpoint tests
- `integration` - Integration tests
- `e2e` - End-to-end tests
- `smoke` - Quick smoke tests
- `regression` - Full regression tests

## Environment Variables

Tests use the following environment variables:
- `API_URL` - API gateway URL (default: http://localhost:8082)
- `SFU_URL` - SFU server URL (default: http://localhost:8080)
- `MQTT_URL` - MQTT broker URL (default: http://localhost:8081)

## CI/CD Integration

Tests are integrated with GitHub Actions:

```yaml
# .github/workflows/ci.yml
- name: Run Robot Framework tests
  run: |
    pip install -r tests/requirements.txt
    robot tests/suites/api/
    robot tests/suites/integration/
```

## Viewing Reports

After running tests, Robot Framework generates:
- `report.html` - Overall test report
- `log.html` - Detailed test log
- `output.xml` - XML output for CI/CD integration

```bash
# Open report in browser
open report.html

# Generate JUnit XML for CI
robot --output output.xml --log NONE --report NONE tests/
```
