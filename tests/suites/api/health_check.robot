*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Resource   ../resources/common.robot
Suite Setup    Create Session
Suite Teardown    Delete All Sessions

*** Variables ***
${AUTH_URL}         ${API_URL}/auth
${ROOMS_URL}        ${API_URL}/rooms
${VERIFY_URL}       ${API_URL}/verify
${WITHDRAW_URL}     ${API_URL}/withdraw

*** Test Cases ***
Health Check
    [Documentation]    Test API health endpoint
    ${response}    GET On Session    aurasync    /health
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}    Parse JSON Response    ${response}
    Should Be Equal As Strings    ${json}[status]    healthy

Register User
    [Documentation]    Test user registration
    ${email}    Generate Random Email
    ${body}    Create Dictionary
    ...    email=${email}
    ...    password=test123456
    ...    role=creator
    ${headers}    Get Headers
    ${response}    POST On Session    aurasync    ${AUTH_URL}/register
    ...    json=${body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    201
    ${json}    Parse JSON Response    ${response}
    Should Not Be Empty    ${json}[message]

Login User
    [Documentation]    Test user login
    ${body}    Create Dictionary
    ...    email=test@aurasync.dev
    ...    password=test123456
    ${headers}    Get Headers
    ${response}    POST On Session    aurasync    ${AUTH_URL}/login
    ...    json=${body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}    Parse JSON Response    ${response}
    Should Not Be Empty    ${json}[token]

Create Room
    [Documentation]    Test room creation
    ${body}    Create Dictionary
    ...    name=Test Room
    ...    type=live_stream
    ${headers}    Get Headers
    ${response}    POST On Session    aurasync    ${ROOMS_URL}
    ...    json=${body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    201
    ${json}    Parse JSON Response    ${response}
    Should Not Be Empty    ${json}[room_id]

List Rooms
    [Documentation]    Test listing rooms
    ${headers}    Get Headers
    ${response}    GET On Session    aurasync    ${ROOMS_URL}
    ...    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}    Parse JSON Response    ${response}
    Should Be True    isinstance(${json}[rooms], list)

Join Room
    [Documentation]    Test joining a room
    ${body}    Create Dictionary
    ...    name=Join Test Room
    ...    type=live_stream
    ${headers}    Get Headers
    ${create_response}    POST On Session    aurasync    ${ROOMS_URL}
    ...    json=${body}    headers=${headers}
    ${create_json}    Parse JSON Response    ${create_response}
    ${room_id}    Set Variable    ${create_json}[room_id]
    
    ${response}    POST On Session    aurasync    ${ROOMS_URL}/${room_id}/join
    ...    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}    Parse JSON Response    ${response}
    Should Be Equal As Strings    ${json}[status]    joined

Verify Age - WorldID
    [Documentation]    Test age verification with WorldID
    ${body}    Create Dictionary
    ...    method=worldid
    ...    token=mock-worldid-token
    ${headers}    Get Headers
    ${response}    POST On Session    aurasync    ${VERIFY_URL}/age
    ...    json=${body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}    Parse JSON Response    ${response}
    Should Be True    ${json}[verified]

Verify Age - Yoti
    [Documentation]    Test age verification with Yoti
    ${body}    Create Dictionary
    ...    method=yoti
    ...    token=mock-yoti-token
    ${headers}    Get Headers
    ${response}    POST On Session    aurasync    ${VERIFY_URL}/age
    ...    json=${body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}    Parse JSON Response    ${response}
    Should Be True    ${json}[verified]

Withdraw Funds
    [Documentation]    Test withdrawal
    ${body}    Create Dictionary
    ...    amount=100.50
    ...    address=0x742d35Cc6634C0532925a3b844Bc9e7595f2bD18
    ...    currency=USDC
    ${headers}    Get Headers
    ${response}    POST On Session    aurasync    ${WITHDRAW_URL}
    ...    json=${body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}    Parse JSON Response    ${response}
    Should Be Equal As Strings    ${json}[status]    withdrawal initiated
    Should Not Be Empty    ${json}[tx_id]

Invalid Login
    [Documentation]    Test login with invalid credentials
    ${body}    Create Dictionary
    ...    email=invalid@aurasync.dev
    ...    password=wrongpassword
    ${headers}    Get Headers
    ${response}    POST On Session    aurasync    ${AUTH_URL}/login
    ...    json=${body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    401

Missing Required Fields
    [Documentation]    Test validation for missing fields
    ${body}    Create Dictionary
    ...    email=test@aurasync.dev
    ${headers}    Get Headers
    ${response}    POST On Session    aurasync    ${AUTH_URL}/register
    ...    json=${body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    400
