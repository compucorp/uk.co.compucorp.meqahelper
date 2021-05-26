<?php
use CRM_Meqahelper_ExtensionUtil as E;

class CRM_Meqahelper_Page_QAHelper extends CRM_Core_Page {

  public function run() {
    $this->assign('membershipTypes', $this->getMembershipTypes());

    parent::run();
  }

  private function getMembershipTypes() {
    $typesResponse = civicrm_api3('MembershipType', 'get', [
      'sequential' => 1,
      'options' => ['limit' => 0],
    ]);

    $membershipTypes = [];
    foreach ($typesResponse['values'] as $type) {
      $membershipTypes[] = $type;
    }

    return $membershipTypes;
  }

}
