<?php

class CRM_Meqahelper_Service_ContactMembershipextrasDetails{

  private $contactId;

  public function __construct($contactId) {
    $this->contactId = $contactId;
  }

  public function lookup() {
    $contactMembershipsResult = civicrm_api3('Membership', 'get', [
      'sequential' => 1,
      'contact_id' =>$this->contactId,
      'contribution_recur_id' => ['IS NOT NULL' => 1],
      'options' => ['limit' => 0, 'sort' => "id desc"],
    ]);
    if ($contactMembershipsResult['count'] == 0) {
      return [];
    }
    $contactMemberships = $contactMembershipsResult['values'];

    $results = [];
    foreach ($contactMemberships as $membership) {
      $paymentPlanId = $membership['contribution_recur_id'];
      $mandate = $this->getMandateDetails($paymentPlanId);
      $membershipPaymentPlan = $this->getPaymentPlanById($paymentPlanId);
      $paymentPlanContributions = $this->getPaymentPlanContributions($paymentPlanId);


      $membership['status_id'] = civicrm_api3('MembershipStatus', 'getvalue', [
        'return' => 'label',
        'id' => $membership['status_id'],
      ]);

      $results[] = [
        'membership' =>  $membership,
        'paymentPlan' =>  $membershipPaymentPlan,
        'paymentPlanContributions' =>  $paymentPlanContributions,
        'mandate' =>  $mandate,
      ];
    }

    return $results;
  }

  private function getMandateDetails($paymentPlanId) {
    $sql = "SELECT dd_mandate.id as id, bank_name, bank_street_address, bank_city, bank_county,  
           bank_postcode, account_holder_name, ac_number, sort_code, dd_code, dd_ref, start_date, authorisation_date   
           FROM civicrm_value_dd_mandate dd_mandate 
           INNER JOIN dd_contribution_recurr_mandate_ref recurr_mandate ON recurr_mandate.mandate_id = dd_mandate.id 
           WHERE recurr_mandate.recurr_id = $paymentPlanId";

    $dao = CRM_Core_DAO::executeQuery($sql);
    $dao->fetch();
    return $dao->toArray();
  }

  private function getPaymentPlanById($paymentPlanId) {
    $result = civicrm_api3('ContributionRecur', 'get', [
      'sequential' => 1,
      'id' => $paymentPlanId,
    ]);
    if ($result['count'] == 0) {
      return [];
    }

    $paymentPlan = $result['values'][0];

    $paymentPlan['auto_renew'] = $paymentPlan['auto_renew'] ? 'True' : 'False';

    $paymentPlan['status'] = civicrm_api3('OptionValue', 'getvalue', [
      'return' => 'label',
      'option_group_id' => 'contribution_recur_status',
      'value' => $paymentPlan['contribution_status_id'],
    ]);

    $paymentPlan['payment_memthod'] = civicrm_api3('OptionValue', 'getvalue', [
      'return' => 'label',
      'option_group_id' => 'payment_instrument',
      'value' => $paymentPlan['payment_instrument_id'],
    ]);

    return $paymentPlan;
  }

  private function getPaymentPlanContributions($paymentPlanId) {
    $mandateCustomFieldId = civicrm_api3('CustomField', 'getvalue', [
      'return' => "id",
      'custom_group_id' => "direct_debit_information",
      'name' => "mandate_id",
    ]);


    $result = civicrm_api3('Contribution', 'get', [
      'sequential' => 1,
      'contribution_recur_id' => $paymentPlanId,
      'options' => ['limit' => 0, 'sort' => 'id asc'],
    ]);
    if ($result['count'] == 0) {
      return [];
    }

    $contributions = [];
    foreach ($result['values'] as $cont) {
      $cont['mandate_id'] = 'NA';
      if (!empty($cont['custom_' . $mandateCustomFieldId])) {
        $cont['mandate_id'] = $cont['custom_' . $mandateCustomFieldId];
      }

      $contributions[] = $cont;
    }

    return $contributions;
  }

}
