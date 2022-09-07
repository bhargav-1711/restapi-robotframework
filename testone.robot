*** Settings ***
Library     RequestsLibrary
Library    Collections

*** Variables ***
${base_url}     https://gorest.co.in/
${cont_url}     public/v2/users
${bearer_key}   Bearer 6b3b3e33a9afbe8e9ed4b4e9f311c84f04f5f13cc3b6e9a507001579dff92ffd

*** Test Cases ***

test case one
    Create Session    myses    ${base_url}
    ${get_res}=     GET On Session  myses   ${cont_url}
    ${headers}=    set variable      ${get_res.headers}
    ${pagination}=    Evaluate    ${headers}.get("x-pagination-pages")

    #pagination is present or not
    IF    ${pagination} != None
        Log To Console    pegination is present
    ELSE
         Log To Console    not present
    END
#    Should Not Be Equal As Strings    ${pagination}    None

    #json data validation
    ${cont_type}=    Get From Dictionary    ${headers}    Content-Type
    Should Be Equal As Strings    application/json; charset=utf-8    ${cont_type}


    #response data has email address or not
    ${resp}=      GET On Session   myses   ${cont_url}
    @{resp_text}=   set variable    ${resp.json()}
    FOR    ${element}    IN    @{resp_text}
        Dictionary Should Contain Key    ${element}    email
    END

    #list data have similar items or not
    ${li_1}=    Get From List    ${resp_text}    0
    ${dict_keys}=   Get Dictionary Keys    ${li_1}
#    Log To Console    ${dict_keys}
    FOR    ${element}    IN    @{resp_text}
        Should Contain    ${element}   @{dict_keys}
    END

    #verifying status codes
    Should Be Equal As Integers    ${get_res.status_code}    200

    #sending post request without authorization
#    ${post_resp}=   POST On Session     myses   ${cont_url}   # Authorization fail
    #sending post request with authorization
    ${headerss}=     Create Dictionary   Authorization=${bearer_key}    Content-Type=application/json
    ${data}=    Create Dictionary   name=nobita   email=nobita@gmail.com   gender=Male    status=active
    ${post_resp}=   POST On Session     myses    ${cont_url}     json=${data}   headers=${headerss}

    Should Be Equal As Integers    ${post_resp.status_code}  201

testcase two
    Create Session    mysess    http://gorest.co.in/

    #verifying non ssl Rest endpoint behaviour
    ${non_ssl_get}=     GET On Session    mysess    ${cont_url}
    Log To Console    nonssl status code ${non_ssl_get.status_code}





