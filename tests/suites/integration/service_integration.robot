*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    Process
Resource   ../resources/common.robot
Suite Setup    Start Services
Suite Teardown    Stop Services

*** Variables ***
${API_URL}          http://localhost:8082/api/v1
${SFU_URL}          http://localhost:8080
${MQTT_URL}         http://localhost:8081
${REDIS_URL}        localhost:6379
${POSTGRES_URL}     localhost:5432
${MONGODB_URL}      localhost:27017

*** Keywords ***
Start Services
    [Documentation]    Start all services for testing
    Create Session    api    ${API_URL}    verify=${False}
    Create Session    sfu    ${SFU_URL}    verify=${False}
    Create Session    mqtt    ${MQTT_URL}    verify=${False}
    
    # Wait for services to be ready
    Wait Until Keyword Succeeds    30s    5s    Check API Health
    Wait Until Keyword Succeeds    30s    5s    Check SFU Health
    Wait Until Keyword Succeeds    30s    5s    Check MQTT Health

Stop Services
    [Documentation]    Stop all services
    Delete All Sessions

Check API Health
    ${response}    GET On Session    api    /health
    Should Be Equal As Strings    ${response.status_code}    200

Check SFU Health
    ${response}    GET On Session    sfu    /health
    Should Be Equal As Strings    ${response.status_code}    200

Check MQTT Health
    ${response}    GET On Session    mqtt    /health
    Should Be Equal As Strings    ${response.status_code}    200

*** Test Cases ***
Service Health Check
    [Documentation]    Verify all services are healthy
    Check API Health
    Check SFU Health
    Check MQTT Health

Database Connectivity - PostgreSQL
    [Documentation]    Test PostgreSQL connection
    ${result}    Run Process    pg_isready    -h    localhost    -p    5432    -U    aurasync
    Should Be Equal As Integers    ${result.rc}    0

Database Connectivity - MongoDB
    [Documentation]    Test MongoDB connection
    ${result}    Run Process    mongosh    --eval    db.runCommand('ping')    --quiet
    Should Contain    ${result.stdout}    ok

Database Connectivity - Redis
    [Documentation]    Test Redis connection
    ${result}    Run Process    redis-cli    -h    localhost    ping
    Should Be Equal As Strings    ${result.stdout}    PONG

User Registration And Login Flow
    [Documentation]    Test complete user registration and login flow
    ${email}    Generate Random Email
    
    # Register
    ${reg_body}    Create Dictionary
    ...    email=${email}
    ...    password=test123456
    ...    role=creator
    ${headers}    Get Headers
    ${reg_response}    POST On Session    api    /auth/register
    ...    json=${reg_body}    headers=${headers}
    Should Be Equal As Strings    ${reg_response.status_code}    201
    
    # Login
    ${login_body}    Create Dictionary
    ...    email=${email}
    ...    password=test123456
    ${login_response}    POST On Session    api    /auth/login
    ...    json=${login_body}    headers=${headers}
    Should Be Equal As Strings    ${login_response.status_code}    200
    ${login_json}    Parse JSON Response    ${login_response}
    Should Not Be Empty    ${login_json}[token]

Room Creation And Joining Flow
    [Documentation]    Test complete room creation and joining flow
    ${headers}    Get Headers
    
    # Create room
    ${room_body}    Create Dictionary
    ...    name=Integration Test Room
    ...    type=live_stream
    ${create_response}    POST On Session    api    /rooms
    ...    json=${room_body}    headers=${headers}
    Should Be Equal As Strings    ${create_response.status_code}    201
    ${create_json}    Parse JSON Response    ${create_response}
    ${room_id}    Set Variable    ${create_json}[room_id]
    
    # Get room details
    ${get_response}    GET On Session    api    /rooms/${room_id}
    ...    headers=${headers}
    Should Be Equal As Strings    ${get_response.status_code}    200
    
    # Join room
    ${join_response}    POST On Session    api    /rooms/${room_id}/join
    ...    headers=${headers}
    Should Be Equal As Strings    ${join_response.status_code}    200
    ${join_json}    Parse JSON Response    ${join_response}
    Should Be Equal As Strings    ${join_json}[status]    joined

Age Verification Flow
    [Documentation]    Test age verification flow with both methods
    ${headers}    Get Headers
    
    # WorldID verification
    ${worldid_body}    Create Dictionary
    ...    method=worldid
    ...    token=mock-proof
    ${worldid_response}    POST On Session    api    /verify/age
    ...    json=${worldid_body}    headers=${headers}
    Should Be Equal As Strings    ${worldid_response.status_code}    200
    ${worldid_json}    Parse JSON Response    ${worldid_response}
    Should Be True    ${worldid_json}[verified]
    
    # Yoti verification
    ${yoti_body}    Create Dictionary
    ...    method=yoti
    ...    token=mock-token
    ${yoti_response}    POST On Session    api    /verify/age
    ...    json=${yoti_body}    headers=${headers}
    Should Be Equal As Strings    ${yoti_response.status_code}    200
    ${yoti_json}    Parse JSON Response    ${yoti_response}
    Should Be True    ${yoti_json}[verified]

Withdrawal Flow
    [Documentation]    Test withdrawal flow
    ${headers}    Get Headers
    
    ${withdraw_body}    Create Dictionary
    ...    amount=50.25
    ...    address=0x742d35Cc6634C0532925a3b844Bc9e7595f2bD18
    ...    currency=USDC
    ${response}    POST On Session    api    /withdraw
    ...    json=${withdraw_body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}    Parse JSON Response    ${response}
    Should Be Equal As Strings    ${json}[status]    withdrawal initiated
    Should Not Be Empty    ${json}[tx_id]

IoT Device Command Flow
    [Documentation]    Test IoT device command sending
    ${headers}    Get Headers
    
    # Send command to device
    ${command_body}    Create Dictionary
    ...    command=activate
    ...    payload={"intensity": 50}
    ${response}    POST On Session    mqtt    /devices/test-device/command
    ...    json=${command_body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    
    # Get device status
    ${status_response}    GET On Session    mqtt    /devices/test-device/status
    ...    headers=${headers}
    Should Be Equal As Strings    ${status_response.status_code}    200
