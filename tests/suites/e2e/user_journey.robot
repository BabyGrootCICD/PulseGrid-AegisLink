*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    SeleniumLibrary
Resource   ../resources/common.robot
Suite Setup    Setup Browser
Suite Teardown    Teardown Browser

*** Variables ***
${BASE_URL}         http://localhost:3000
${API_URL}          http://localhost:8082/api/v1

*** Keywords ***
Setup Browser
    [Documentation]    Setup browser for E2E testing
    Open Browser    ${BASE_URL}    chrome    options=add_argument('--no-sandbox');add_argument('--disable-dev-shm-usage')
    Set Browser Implicit Wait    10s

Teardown Browser
    [Documentation]    Teardown browser
    Close All Browsers

Navigate To Home
    [Documentation]    Navigate to home page
    Go To    ${BASE_URL}
    Wait Until Page Contains    PulseGrid-AegisLink

Navigate To Age Verification
    [Documentation]    Navigate to age verification
    Click Button    Verify Age
    Wait Until Element Is Visible    css=[data-testid="age-verification-modal"]

*** Test Cases ***
Home Page Loads
    [Documentation]    Test that home page loads correctly
    Navigate To Home
    Page Should Contain    PulseGrid-AegisLink
    Page Should Contain    AuraSync Platform
    Page Should Contain    Interactive adult entertainment broadcasting

Navigation Links
    [Documentation]    Test navigation links
    Navigate To Home
    Page Should Contain Link    /
    Page Should Contain Link    /rooms
    Page Should Contain Link    /counseling

Age Verification Modal
    [Documentation]    Test age verification modal
    Navigate To Home
    Navigate To Age Verification
    Page Should Contain    Verify with World ID
    Page Should Contain    Verify with Yoti
    Page Should Contain Button    Continue with World ID
    Page Should Contain Button    Continue with Yoti

Room Listing Page
    [Documentation]    Test room listing page
    Navigate To Home
    Click Link    /rooms
    Wait Until Page Contains    Available Rooms
    Page Should Contain Element    css=[data-testid="room-list"]

Room Creation Form
    [Documentation]    Test room creation form
    Navigate To Home
    Click Link    /rooms/create
    Wait Until Page Contains    Create Room
    Page Should Contain Element    css=[name="roomName"]
    Page Should Contain Element    css=[name="roomType"]
    Page Should Contain Button    Create Room

Counseling Booking Page
    [Documentation]    Test counseling booking page
    Navigate To Home
    Click Link    /counseling
    Wait Until Page Contains    Book a Session
    Page Should Contain Element    css=[data-testid="counselor-list"]

Counselor Selection
    [Documentation]    Test counselor selection
    Navigate To Home
    Click Link    /counseling
    Wait Until Element Is Visible    css=[data-testid="counselor-card"]:first-child
    Click Element    css=[data-testid="counselor-card"]:first-child
    Wait Until Page Contains    Book Session

Wallet Connection
    [Documentation]    Test wallet connection
    Navigate To Home
    Click Link    /wallet
    Wait Until Page Contains    Connect Wallet
    Page Should Contain Button    Connect Phantom

Withdrawal Panel
    [Documentation]    Test withdrawal panel
    Navigate To Home
    Click Link    /wallet/withdraw
    Wait Until Page Contains    Creator Withdrawal
    Page Should Contain Element    css=[name="amount"]
    Page Should Contain Button    Withdraw Funds
    Page Should Contain    Do not withdraw directly to Binance

Error Handling - 404
    [Documentation]    Test 404 error handling
    Go To    ${BASE_URL}/nonexistent
    Wait Until Page Contains    404
    Page Should Contain    Page Not Found

Error Handling - Network Error
    [Documentation]    Test network error handling
    Go To    ${BASE_URL}/api/nonexistent
    Wait Until Page Contains    Error

Responsive Design - Mobile
    [Documentation]    Test responsive design on mobile viewport
    Set Window Size    375    812    # iPhone X
    Navigate To Home
    Page Should Be Visible    css=[data-testid="mobile-menu-toggle"]

Responsive Design - Tablet
    [Documentation]    Test responsive design on tablet viewport
    Set Window Size    768    1024    # iPad
    Navigate To Home
    Page Should Be Visible    css=[data-testid="navigation"]

Form Validation
    [Documentation]    Test form validation
    Navigate To Home
    Click Link    /rooms/create
    Click Button    Create Room
    Wait Until Page Contains    Please fill in all required fields
