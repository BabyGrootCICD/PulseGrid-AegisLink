*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    DateTime

*** Variables ***
${BASE_URL}         http://localhost:8082
${API_URL}          ${BASE_URL}/api/v1
${CONTENT_TYPE}     application/json

*** Keywords ***
Create Session
    [Documentation]    Create a new HTTP session
    Create Session    aurasync    ${BASE_URL}    verify=${False}

Get Headers
    [Documentation]    Get common headers
    ${headers}    Create Dictionary    Content-Type=${CONTENT_TYPE}
    RETURN    ${headers}

Get Auth Headers
    [Documentation]    Get headers with authorization token
    [Arguments]    ${token}
    ${headers}    Create Dictionary
    ...    Content-Type=${CONTENT_TYPE}
    ...    Authorization=Bearer ${token}
    RETURN    ${headers}

Generate Random Email
    [Documentation]    Generate a random email address
    ${random}    Generate Random String    8    [LOWER]
    RETURN    test_${random}@aurasync.dev

Generate Random String
    [Documentation]    Generate a random string
    [Arguments]    ${length}=10
    ${random}    Generate Random String    ${length}    [LOWER]
    RETURN    ${random}

Parse JSON Response
    [Documentation]    Parse JSON response
    [Arguments]    ${response}
    ${json}    Evaluate    json.loads('''${response.text}''')    json
    RETURN    ${json}
