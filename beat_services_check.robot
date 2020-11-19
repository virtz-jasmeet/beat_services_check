*** Settings ***
Documentation                  Check and validate filebeat, metrricbeat & auditbeat service and configuration
Library                        SSHLibrary
Suite Teardown                 Close All Connections


*** Variables ***
@{ALLHOSTS}=        10.189.153.69  10.189.153.70  10.189.153.71  10.189.153.72  10.189.153.73  10.189.153.74  10.189.153.75
@{CONTROLLERS}=     10.189.153.69  10.189.153.70  10.189.153.71
@{COMPUTES}=        10.189.153.72  10.189.153.73  10.189.153.74  10.189.153.75
${USERNAME}         root
${PASSWORD}         STRANGE-EXAMPLE-neither

*** Test Cases ***
Check auditbeat service should be running on all Controllers
    [Documentation]			Check auditbeat service should be running on all Controllers
    FOR  ${HOST}  IN  @{CONTROLLERS}
        open connection         ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        ${output}=              execute command  systemctl list-units --type=service --all | grep -i auditbeat.service | awk -F"auditbeat.service" '{print $2}' | awk '{print $2}'
        Should Be Equal         ${output}  active
        close connection
    END

Check auditbeat config should match on all Controllers
    [Documentation]			Check auditbeat config should match on all Controllers
    FOR  ${HOST}  IN  @{CONTROLLERS}
        open connection		    ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        Put File                auditbeat.yml_config_data  /root  mode=0660
        SSHLibrary.File Should Exist   /root/auditbeat.yml_config_data
        ${output}=              execute command   diff -is /root/auditbeat.yml_config_data /etc/auditbeat/auditbeat.yml
        Run Keyword And Continue On Failure     should contain    ${output}    identical
        execute command         rm -f /root/auditbeat.yml_config_data
        close connection
    END

Check filebeat service should be running
    [Documentation]			Check filebeat service should be running
    FOR  ${HOST}  IN  @{ALLHOSTS}
        open connection         ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        ${output}=              execute command  systemctl list-units --type=service --all | grep -i filebeat.service | awk -F"filebeat.service" '{print $2}' | awk '{print $2}'
        Should Be Equal         ${output}  active
        close connection
    END

Check filebeat config should match
    [Documentation]			Check filebeat config should match
    FOR  ${HOST}  IN  @{ALLHOSTS}
        open connection		    ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        Put File                filebeat.yml_config_data  /root  mode=0660
        SSHLibrary.File Should Exist   /root/filebeat.yml_config_data
        ${output}=              execute command   diff -is /root/filebeat.yml_config_data /etc/filebeat/filebeat.yml
        Run Keyword And Continue On Failure     should contain    ${output}    identical
        execute command         rm -f /root/filebeat.yml_config_data
        close connection
    END

Check metricbeat service should be running
    [Documentation]			Check metricbeat service should be running
    FOR  ${HOST}  IN  @{ALLHOSTS}
        open connection         ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        ${output}=              execute command  systemctl list-units --type=service --all | grep -i metricbeat.service | awk -F"metricbeat.service" '{print $2}' | awk '{print $2}'
        Should Be Equal         ${output}  active
        close connection
    END

Check metricbeat config should match
    [Documentation]			Check metricbeat config should match
    FOR  ${HOST}  IN  @{ALLHOSTS}
        open connection		    ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        Put File                metricbeat.yml_config_data  /root  mode=0660
        SSHLibrary.File Should Exist   /root/metricbeat.yml_config_data
        ${output}=              execute command   diff -is -I virtz02-os1 -I 10.189.153 /root/metricbeat.yml_config_data /etc/metricbeat/metricbeat.yml
        Run Keyword And Continue On Failure     should contain    ${output}    identical
        execute command         rm -f /root/metricbeat.yml_config_data
        close connection
    END

*** Keywords ***

