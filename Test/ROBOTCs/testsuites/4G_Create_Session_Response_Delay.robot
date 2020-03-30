#
# Copyright (c) 2019, Infosys Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");ttach_S1Release.robot
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
*** Settings ***
Suite Setup       Attach Suite Setup
Suite Teardown    Attach Suite Teardown
Resource          ../keywords/robotkeywords/HighLevelKeyword.robot
Resource          ../keywords/robotkeywords/MMEAttachCallflow.robot
Resource          ../keywords/robotkeywords/StringFunctions.robot
*** Test Cases ***
TC1: LTE 4G S11 Create Session Response Delay
    [Documentation]     Timeout Scenario of Create Session Response
    [Tags]    TC1    LTE_4G_Create_Session_Response_Delay    Attach    Detach
    [Setup]    Attach Test Setup
    Switch Connection    ${serverID}
    ${procStatOutBfExec1}    Execute Command    pwd
    Log    ${procStatOutBfExec1}
    Switch Connection    ${serverID}
    ${procStatbfExec}    ${stderr}    Execute Command    export LD_LIBRARY_PATH=${openMmeLibPath} && ${mmeGrpcClientPath}/mme-grpc-client mme-app show procedure-stats    timeout=30s    return_stderr=True
    Log    ${procStatbfExec}
    ${num_of_subscribers_attached}    ${found}    Get Key Value From Dict    ${statsTypes}    subs_attached
    ${ueCountBeforeAttach}    Get GRPC Stats Response Count    ${procStatbfExec}    ${num_of_subscribers_attached}
    ${ueCountBeforeAttach}    Convert to Integer    ${ueCountBeforeAttach}
    ${num_of_cs_resp_timeout}    ${found}    Get Key Value From Dict    ${statsTypes}    cs_resp_timeout
    ${csRespTimeoutCountBf}    Get GRPC Stats Response Count    ${procStatbfExec}    ${num_of_cs_resp_timeout}
    ${csRespTimeoutCountBf}    Convert to Integer    ${csRespTimeoutCountBf}
    Send S1ap    attach_request    ${initUeMessage_AttachReq}    ${enbUeS1APId}    ${nasAttachRequest}    ${IMSI}    #Send Attach Request to MME
    ${air}    Receive S6aMsg    #HSS Receives AIR from MME
    Send S6aMsg    authentication_info_response    ${msgData_aia}    ${IMSI}    #HSS sends AIA to MME
    ${authReqResp}    Receive S1ap    #Auth Request received from MME
    Send S1ap    authentication_response    ${uplinkNASTransport_AuthResp}    ${enbUeS1APId}    ${nasAuthenticationResponse}    #Send Auth Response to MME
    ${secModeCmdRecd}    Receive S1ap    #Security Mode Command received from MME
    Send S1ap    security_mode_complete    ${uplinkNASTransport_SecModeCmp}    ${enbUeS1APId}    ${nasSecurityModeComplete}    #Send Security Mode Complete to MME
    ${esmInfoReq}    Receive S1ap    #ESM Information Request from MME
    Send S1ap    esm_information_response    ${uplinknastransport_esm_information_response}    ${enbUeS1APId}    ${nas_esm_information_response}    #ESM Information Response to MME
    ${ulr}    Receive S6aMsg    #HSS receives ULR from MME
    Send S6aMsg     update_location_response    ${msgData_ula}    ${IMSI}   #HSS sends ULA to MME
    Set Global Variable    ${CLR_Flag}    Yes
    ${createSessReqRecdFromMME}    Receive GTP    #Create Session Request received from MME
    Sleep    5s
    ${attachreject}    Receive S1ap    #Attach Reject recieved from MME
    ${intlCntxReleaseCmd}    Receive S1ap    #Initial Context Release Command received from MME
    Send S1ap    ue_context_release_cmp    ${ueContextReleaseCmp}    ${enbUeS1APId}    #eNB sends UE Context Release Complete to MME    #eNB sends UE Context Release Complete to MME
    ${procStatTimeOut}    ${stderr}    Execute Command    export LD_LIBRARY_PATH=${openMmeLibPath} && ${mmeGrpcClientPath}/mme-grpc-client mme-app show procedure-stats    timeout=30s    return_stderr=True
    Log    ${procStatTimeOut}
    ${csRespTimeoutCountAf}    Get GRPC Stats Response Count    ${procStatTimeOut}    ${num_of_cs_resp_timeout}
    ${csRespTimeoutCountAf}    Convert to Integer    ${csRespTimeoutCountAf}
    ${incrementCsRespTimeoutCount}    Evaluate    ${csRespTimeoutCountBf}+1
    Should Be Equal    ${incrementCsRespTimeoutCount}    ${csRespTimeoutCountAf}    Expected Create Session resp Count: ${incrementCsRespTimeoutCount}, but Received Create Session Count: ${CsRespTimeoutCountAf}    values=False
    
    Send S1ap    attach_request    ${initUeMessage_AttachReq}    ${enbUeS1APId}    ${nasAttachRequest}    ${IMSI}    #Send Attach Request to MME
    ${air}    Receive S6aMsg    #HSS Receives AIR from MME
    Send S6aMsg    authentication_info_response    ${msgData_aia}    ${IMSI}    #HSS sends AIA to MME
    ${authReqResp}    Receive S1ap    #Auth Request received from MME
    Send S1ap    authentication_response    ${uplinkNASTransport_AuthResp}    ${enbUeS1APId}    ${nasAuthenticationResponse}    #Send Auth Response to MME
    ${secModeCmdRecd}    Receive S1ap    #Security Mode Command received from MME
    Send S1ap    security_mode_complete    ${uplinkNASTransport_SecModeCmp}    ${enbUeS1APId}    ${nasSecurityModeComplete}    #Send Security Mode Complete to MME
    ${esmInfoReq}    Receive S1ap    #ESM Information Request from MME
    Send S1ap    esm_information_response    ${uplinknastransport_esm_information_response}    ${enbUeS1APId}    ${nas_esm_information_response}    #ESM Information Response to MME
    ${ulr}    Receive S6aMsg    #HSS receives ULR from MME
    Send S6aMsg     update_location_response    ${msgData_ula}    ${IMSI}   #HSS sends ULA to MME
    ${createSessReqRecdFromMME}    Receive GTP    #Create Session Request received from MME
    Send GTP    create_session_response    ${createSessionResp}    ${gtpMsgHeirarchy_tag1}    #Send Create Session Response to MME
    ${intContSetupReqRec}    Receive S1ap    #Initial Context Setup Request received from MME
    Send S1ap    initial_context_setup_response    ${initContextSetupRes}    ${enbUeS1APId}    #Send Initial Context Setup Response to MME
    Sleep    1s
    Send S1ap    uplink_nas_transport_attach_cmp    ${uplinkNASTransport_AttachCmp}    ${enbUeS1APId}    ${nasAttachComplete}    #Send Attach Complete to MME
    ${modBearReqRec}    Receive GTP    #Modify Bearer Request received from MME
    Send GTP    modify_bearer_response    ${modifyBearerResp}    ${gtpMsgHeirarchy_tag2}    #Send Modify Bearer Response to MME
    ${recEMMInfo}    Receive S1ap    #EMM Information received from MME
    Sleep    1s
    ${mmeUeS1APId}    ${mmeUeS1APIdPresent}    Get Key Value From Dict    ${intContSetupReqRec}    MME-UE-S1AP-ID
    ${IMSI_str}    Convert to String    ${IMSI}
    ${mobContextAftExec}    Execute Command    export LD_LIBRARY_PATH=${openMmeLibPath} && ${mmeGrpcClientPath}/mme-grpc-client mme-app show mobile-context ${mmeUeS1APId}    timeout=30s
    Log    ${mobContextAftExec}
    Should Contain    ${mobContextAftExec}    ${IMSI_str}    Expected IMSI: ${IMSI_str}, but Received ${mobContextAftExec}    values=False
    Should Contain    ${mobContextAftExec}    EpsAttached    Expected UE State: EpsAttached, but Received ${mobContextAftExec}    values=False
    Send S1ap    detach_request    ${uplinkNASTransport_DetachReq}    ${enbUeS1APId}    ${nasDetachRequest}    #Send Detach Request to MME
    ${delSesReqRec}    Receive GTP    #Delete Session Request received from MME
    Send GTP    delete_session_response    ${deleteSessionResp}    ${gtpMsgHeirarchy_tag3}    #Send Delete Session Response to MME
    ${detAccUE}    Receive S1ap    #MME send Detach Accept to UE
    ${eNBUeRelReqFromMME}    Receive S1ap    #eNB receives UE Context Release Request from MME
    Send S1ap    ue_context_release_cmp    ${ueContextReleaseCmp}    ${enbUeS1APId}    #eNB sends UE Context Release Complete to MME    #eNB sends UE Context Release Complete to MME
    Sleep    1s
    ${procStatOutAfDetach}    Execute Command    export LD_LIBRARY_PATH=${openMmeLibPath} && ${mmeGrpcClientPath}/mme-grpc-client mme-app show procedure-stats    timeout=30s
    Log    ${procStatOutAfDetach}
    ${ueCountAfterDetach}    Get GRPC Stats Response Count    ${procStatOutAfDetach}    ${num_of_subscribers_attached}
    ${ueCountAfterDetach}    Convert to Integer    ${ueCountAfterDetach}
    Should Be Equal    ${ueCountBeforeAttach}    ${ueCountAfterDetach}    Expected UE Detach Count: ${ueCountBeforeAttach}, but Received UE Detach Count: ${ueCountAfterDetach}    values=False
    [Teardown]    Attach Test Teardown