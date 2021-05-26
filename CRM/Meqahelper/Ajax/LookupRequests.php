<?php

class CRM_Meqahelper_Ajax_LookupRequests{

  public static function lookupDetails() {
    $contactId = CRM_Utils_Request::retrieve('contactId', 'Integer');

    $dataLooker = new CRM_Meqahelper_Service_ContactMembershipextrasDetails($contactId);
    CRM_Utils_JSON::output($dataLooker->lookup());
  }

  public static function lookupSchedule() {
    $membershipTypeId = CRM_Utils_Request::retrieve('membershipTypeID', 'Integer');
    $ppSchedule = CRM_Utils_Request::retrieve('ppSchedule', 'String');
    $startDate = CRM_Utils_Request::retrieve('startDate', 'String');
    $endDate = CRM_Utils_Request::retrieve('endDate', 'String');

    $dataLooker = new CRM_Meqahelper_Service_PaymentSchedule($membershipTypeId, $ppSchedule, $startDate, $endDate);
    CRM_Utils_JSON::output($dataLooker->lookup());
  }

}
