####################################################
#!!
#! @description: This flow is used to perform a REST Put request to any ServiceNow table. It performs an update of the fields mentioned in the body.
#!               The fields that do not appear in the body of this request will remain unchanged.
#! @input host: required - The URL of the ServiceNow instance
#!              Example: 'dev10000.service-now.com'
#! @input protocol: optional - The protocol that is used to send the request
#!                  Valid: https
#!                  Default: https
#! @input auth_type: optional - type of authentication used to execute the request on the target server
#!                   Valid: 'basic', 'anonymous' (When OAuth token is provided)
#!                   Default: 'basic'
#! @input api_version: optional - the servicenow api version to be used for the call
#!                   Valid: 'v1', 'v2'
#!                   Default: ''
#! @input table_name: required - the name of the servicenow table which should be used for the request.
#!                    Example: incident, problem , change
#! @input system_id: required - the system id of the record to be updated
#! @input username: optional - username used for URL authentication; for NTLM authentication, the required format is
#!                  'domain\user'
#! @input password: optional - password used for URL authentication
#! @input proxy_host: optional - proxy server used to access the web site
#! @input proxy_port: optional - proxy server port - Default: '8080'
#! @input proxy_username: optional - user name used when connecting to the proxy
#! @input proxy_password: optional - proxy server password associated with the <proxyUsername> input value
#! @input connect_timeout: optional - time in seconds to wait for a connection to be established - Default: '0' (infinite)
#! @input socket_timeout: optional - time in seconds to wait for data to be retrieved - Default: '0' (infinite)
#! @input headers: optional - list containing the headers to use for the request separated by new line (CRLF);
#!                 header name - value pair will be separated by ":" - Format: According to HTTP standard for
#!                 headers (RFC 2616) - Example: 'Accept:text/plain'
#! @input query_params: optional - list containing query parameters to append to the URL
#!                      Example: 'parameterName1=parameterValue1&parameterName2=parameterValue2;'
#! @input body: optional - The string to include in the body of the request, in the format accepted by ServiceNow.
#!              Example: {'short_description':'Example description','severity':'1','assigned_to':'46c1293aa9fe1981000dc753e75ebeee'}
#! @input content_type: optional - content type that should be set in the request header, representing the MIME-type of the
#!                      data in the message body - Default: 'application/sjon'
#! @output return_result: the response of the operation in case of success or the error message otherwise
#! @output error_message: return_result if status_code is not contained in interval between '200' and '299'
#! @output return_code: '0' if success, '-1' otherwise
#! @output status_code: status code of the HTTP call
#!!#
################################################

namespace: io.cloudslang.itsm.service_now.commons

imports:
  http: io.cloudslang.base.http

flow:
  name: update_record

  inputs:
    - host
    - protocol:
        required: false
        default: "https"
    - auth_type:
        required: false
        default: "basic"
    - api_version:
        required: false
        default: ''
    - table_name
    - system_id
    - username:
        required: false
        default: ''
    - password:
        required: false
        default: ''
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
    - body:
        required: false
        default: ''
    - content_type:
        default: "application/json"
        required: false

  workflow:
    - update_record:
        do:
          http.http_client_put:
            - url: >
                ${protocol + '://' + host + '/api/now/table/' + table_name + '/' + system_id}
            - auth_type
            - username
            - password
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
            - connect_timeout
            - socket_timeout
            - headers
            - query_params
            - body
            - content_type

        publish:
          - return_result
          - error_message
          - return_code
          - status_code

        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: REST_POST_API_CALL_FAILURE



  outputs:
    - return_result
    - error_message
    - return_code
    - status_code

  results:
    - SUCCESS
    - REST_POST_API_CALL_FAILURE
