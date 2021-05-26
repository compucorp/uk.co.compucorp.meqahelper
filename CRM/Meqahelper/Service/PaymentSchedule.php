<?php

class CRM_Meqahelper_Service_PaymentSchedule {

  private $membershipTypeId;

  private $ppSchedule;

  private $startDate;

  private $endDate;

  public function __construct($membershipTypeId, $ppSchedule, $startDate, $endDate) {
    $this->membershipTypeId = $membershipTypeId;
    $this->ppSchedule = $ppSchedule;
    $this->startDate = $startDate;
    $this->endDate = $endDate;
  }

  public function lookup() {
    $params = [
      'membership_type_id' => $this->membershipTypeId,
      'schedule' => $this->ppSchedule,
    ];

    if (!empty($this->startDate)) {
      $params['start_date'] = $this->startDate;
    }

    if (!empty($this->endDate)) {
      $params['end_date'] = $this->endDate;
    }

    return civicrm_api3('PaymentSchedule', 'getbymembershiptype', $params)['values'];
  }

}
