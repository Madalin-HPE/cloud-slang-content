####################################################
#!!
#! @description: This flow is used to retrieve an OAuth token from ServiceNow.
#! @input host: required - The URL of the ServiceNow instance
#!              Example: 'dev10000.service-now.com'
#! @input protocol: optional - The protocol that is used to send the request
#!                  Valid: https
#!                  Default: https
#! @input auth_type: optional - type of authentication used to execute the request on the target server
#!                   Valid: 'anonymous'
#!                   Default: 'anonymous'
#! @input username: required - The ServiceNow username used to perform the request.
#! @input password: required - The ServiceNow password used to perform the request.
#! @input client_id: required - The Client ID associated with the username that is used to perform the request.
#! @input client_secret: required - The Client Secret associated with the username that is used to perform the request.
#! @input proxy_host: optional - proxy server used to access the web site
#! @input proxy_port: optional - proxy server port - Default: '8080'
#! @input proxy_username: optional - user name used when connecting to the proxy
#! @input proxy_password: optional - proxy server password associated with the <proxy_username> input value
#! @input connect_timeout: optional - time in seconds to wait for a connection to be established - Default: '0' (infinite)
#! @input socket_timeout: optional - time in seconds to wait for data to be retrieved - Default: '0' (infinite)
#! @input headers: optional - list containing the headers to use for the request separated by new line (CRLF);
#!                 header name - value pair will be separated by ":" - Format: According to HTTP standard for
#!                 headers (RFC 2616) - Default: 'application/sjon'
#! @input query_params: optional - list containing query parameters to append to the URL
#!                      Example: 'parameterName1=parameterValue1&parameterName2=parameterValue2;'
#! @input content_type: optional - content type that should be set in the request header, representing the MIME-type of the
#!                      data in the message body - Default: 'application/json'
#! @output return_result: the response of the operation in case of success or the error message otherwise
#! @output error_message: return_result if status_code different than '200'
#! @output return_code: '0' if success, '-1' otherwise
#! @output status_code: status code of the HTTP call
#!!#
################################################

namespace: io.cloudslang.itsm.service_now

imports:
  http: io.cloudslang.base.http
  json: io.cloudslang.base.json

flow:
  name: get_oauth_token

  inputs:
    - host
    - protocol:
        required: false
        default: "https"
    - auth_type:
        required: false
        default: "anonymous"
    - username
    - password
    - client_id
    - client_secret
    - proxy_host:
        required: false
        default: ''
    - proxy_port:
        default: "8080"
        required: false
    - proxy_username:
        required: false
        default: ''
    - proxy_password:
        required: false
        default: ''
    - trust_keystore:
        default: ''
        required: false
    - trust_password:
        default: ''
        required: false
        sensitive: true
    - connect_timeout:
        default: "0"
        required: false
    - socket_timeout:
        default: "0"
        required: false
    - headers:
        required: false
        default: ''
    - query_params:
        required: false
        default: ''
    - content_type:
        default: "application/json"
        required: false

  workflow:
    - get_oauth_token:
        do:
          http.http_client_post:
            - url: >
                ${protocol + '://' + host + '/oauth_token.do'}
            - auth_type
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
            - connect_timeout
            - socket_timeout
            - headers
            - query_params
            - body: >
                ${'grant_type=password&client_id=' + client_id + '&client_secret=' + client_secret + '&username=' + username + '&password=' + password}
            - content_type
        publish:
          - return_result
          - error_message
          - return_code
          - status_code

        navigate:
          - SUCCESS: get_access_token
          - FAILURE: FAILURE
    - get_access_token:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: ['access_token']
        publish:
          - oauth_token: ${value}

        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE

  outputs:
    - oauth_token
    - return_result
    - error_message
    - return_code
    - status_code
