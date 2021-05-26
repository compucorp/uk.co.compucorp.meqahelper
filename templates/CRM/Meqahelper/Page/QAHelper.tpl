<p>Check Membership expected payment schedule by type and dates:</p>
<select id="membership_type" type="text" placeholder="Membership Type ..">
  <option value="">Select Membership Type ..</option>
  {foreach from=$membershipTypes item=type}
      <option value="{$type.id}">{$type.name}</option>
  {/foreach}
</select>

<select id="pp_schedule" type="text" placeholder="Schedule ..">
  <option value="">Select Schedule..</option>
  <option value="monthly">Monthly</option>
  <option value="quarterly">Quarterly</option>
  <option value="annual">Annual</option>
</select>

<input id="membership_start_date" type="text" placeholder="Start Date .."/>
<input id="membership_end_date" type="text" placeholder="End Date .."/>
<button id="lookup_schedule">Show expected schedule</button>

<div id="schedule-content">
</div>


<br><br><br>

<p>Enter Contact Id and click "Lookup" to show all their payment plan memberships  related information:</p>
<input id="contact_id" type="text" placeholder="Contact Id.."/> <button id="lookup">Lookup</button>
<br><br>

<div id="lookup-content">
</div>

{literal}
<script>
    CRM.$( "#membership_start_date" ).addClass('dateplugin').datepicker({'dateFormat' : 'yy-mm-dd'});
    CRM.$( "#membership_end_date" ).addClass('dateplugin').datepicker({'dateFormat' : 'yy-mm-dd'});

    CRM.$('#lookup_schedule').click(function(event){
        membershipTypeID = CRM.$('#membership_type').val();
        startDate = CRM.$('#membership_start_date').val();
        endDate = CRM.$('#membership_end_date').val();
        ppSchedule = CRM.$('#pp_schedule').val();

        CRM.$.ajax({
            "dataType": 'json',
            "type": "GET",
            "url": 'me-qa-helper/lookup-schedule',
            "data": {'membershipTypeID': membershipTypeID, 'ppSchedule': ppSchedule, 'startDate': startDate, 'endDate': endDate},
            "success": function(response) {
                updateScheduleContent(response);
            }
        });
    });

    function updateScheduleContent(response) {
        CRM.$('#schedule-content').html('');
        var table = '' +
            '<table class="selector row-highlight">' +
            '<tr><td><b>Membership Start Date</b></td><td>' + response.membership_start_date + '</td></tr>' +
            '<tr><td><b>Membership End Date</b></td><td>' + response.membership_end_date + '</td></tr>' +
            '<tr><td><b>Total Amount</b></td><td>' + response.total_amount + '</td></tr>' +
            '<tr><td><b>Tax Amount</b></td><td>' + response.tax_amount + '</td></tr>' +
            '</table>';
        CRM.$('#schedule-content').append(table);

        CRM.$('#schedule-content').append('<h3>Installments</h3>');
        for (row of response.instalments) {
            CRM.$('#schedule-content').append('<h3 style="background-color: silver;font-size: 13px;font-weight:unset;">Installment : ' +  row.instalment_no + '</h3>');
            var table = '' +
                '<table class="selector row-highlight">' +
                '<tr><td><b>Installment Date</b></td><td>' + row.instalment_date +'</td></tr>' +
                '<tr><td><b>Installment Total Amount</b></td><td>' + row.instalment_total_amount +'</td></tr>' +
                '<tr><td><b>Installment Tax Amount</b></td><td>' + row.instalment_tax_amount +'</td></tr>' +
                '<tr><td><b>Installment Amount</b></td><td>' + row.instalment_amount +'</td></tr>' +
                '</table>';
            CRM.$('#schedule-content').append(table);
        }
    }

    CRM.$('#lookup').click(function(event){
        contactId = CRM.$('#contact_id').val();
        CRM.$.ajax({
            "dataType": 'json',
            "type": "GET",
            "url": 'me-qa-helper/lookup',
            "data": {'contactId': contactId},
            "success": function(response) {
                updateLookupContent(response);
            }
        });
    });

    function updateLookupContent(response) {
        CRM.$('#lookup-content').html('');
        for (row of response) {
            CRM.$('#lookup-content').append('<h3 style="background-color: lightgreen;font-size: 18px;">Membership with Id: ' + row.membership.id +'</h3>');
            var table = '' +
                '<table class="selector row-highlight">' +
                '<tr><td><b>Type</b></td><td>' + row.membership.membership_name + '</td></tr>' +
                '<tr><td><b>Start Date</b></td><td>' + row.membership.start_date + '</td></tr>' +
                '<tr><td><b>End Date</b></td><td>' + row.membership.end_date + '</td></tr>' +
                '<tr><td><b>Status</b></td><td>' + row.membership.status_id + '</td></tr>' +
                '</table>';
            CRM.$('#lookup-content').append(table);

            CRM.$('#lookup-content').append('<h3>Payment Plan</h3>');
            var table = '' +
                '<table class="selector row-highlight">' +
                '<tr><td><b>Amount</b></td><td>' + row.paymentPlan.amount + ' ' + row.paymentPlan.currency + '</td></tr>' +
                '<tr><td><b>Start Date</b></td><td>' + row.paymentPlan.start_date + '</td></tr>' +
                '<tr><td><b>Installments</b></td><td>' + row.paymentPlan.installments + ', Every ' + row.paymentPlan.frequency_interval + ' ' + row.paymentPlan.frequency_unit + '</td></tr>' +
                '<tr><td><b>Status</b></td><td>' + row.paymentPlan.status + '</td></tr>' +
                '<tr><td><b>Cycle Day</b></td><td>' + row.paymentPlan.cycle_day + '</td></tr>' +
                '<tr><td><b>Auto Renew?</b></td><td>' + row.paymentPlan.auto_renew + '</td></tr>' +
                '<tr><td><b>Payment Method</b></td><td>' + row.paymentPlan.payment_memthod + '</td></tr>' +
                '</table>';
            CRM.$('#lookup-content').append(table);

            if (row.mandate.bank_name) {
                CRM.$('#lookup-content').append('<h3>Mandate with Id = ' + row.mandate.id + ' exists and attached to the payment plan above' + '</h3>');
                var table = '' +
                    '<table class="selector row-highlight">' +
                    '<tr><td><b>A/C Number</b></td><td>' + row.mandate.ac_number +'</td></tr>' +
                    '<tr><td><b>Account Holder Name</b></td><td>' + row.mandate.account_holder_name +'</td></tr>' +
                    '<tr><td><b>Authorisation Date</b></td><td>' + row.mandate.authorisation_date +'</td></tr>' +
                    '<tr><td><b>Bank City</b></td><td>' + row.mandate.bank_city +'</td></tr>' +
                    '<tr><td><b>Bank County</b></td><td>' + row.mandate.bank_county +'</td></tr>' +
                    '<tr><td><b>Bank Name</b></td><td>' + row.mandate.bank_name +'</td></tr>' +
                    '<tr><td><b>Bank Postcode</b></td><td>' + row.mandate.bank_postcode +'</td></tr>' +
                    '<tr><td><b>Bank Streed Address</b></td><td>' + row.mandate.bank_street_address +'</td></tr>' +
                    '<tr><td><b>DD Code</b></td><td>' + row.mandate.dd_code +'</td></tr>' +
                    '<tr><td><b>DD Ref</b></td><td>' + row.mandate.dd_ref +'</td></tr>' +
                    '<tr><td><b>Sort Code</b></td><td>' + row.mandate.sort_code +'</td></tr>' +
                    '<tr><td><b>Start Date</b></td><td>' + row.mandate.start_date +'</td></tr>' +
                    '</table>';
                CRM.$('#lookup-content').append(table);
            }

            CRM.$('#lookup-content').append('<h3>Contributions</h3>');
            for (contRow of row.paymentPlanContributions) {
                CRM.$('#lookup-content').append('<h3 style="background-color: silver;font-size: 13px;font-weight:unset;">Contribution id: ' +  contRow.id + '</h3>');
                var table = '' +
                    '<table class="selector row-highlight">' +
                    '<tr><td><b>Receive Date</b></td><td>' + contRow.receive_date +'</td></tr>' +
                    '<tr><td><b>Payment Method</b></td><td>' + contRow.payment_instrument +'</td></tr>' +
                    '<tr><td><b>Status</b></td><td>' + contRow.contribution_status +'</td></tr>' +
                    '<tr><td><b>Total Amount</b></td><td>' + contRow.total_amount + ' ' + contRow.currency + '</td></tr>' +
                    '<tr><td><b>Net Amount</b></td><td>' + contRow.net_amount + ' ' + contRow.currency + '</td></tr>' +
                    '<tr><td><b>Fee Amount</b></td><td>' + contRow.fee_amount + ' ' + contRow.currency + '</td></tr>' +
                    '<tr><td><b>Fee Amount</b></td><td>' + contRow.fee_amount + ' ' + contRow.currency + '</td></tr>' +
                    '<tr><td><b>Connected To Mandate: </b></td><td>' + contRow.mandate_id + '</td></tr>' +
                    '</table>';
                CRM.$('#lookup-content').append(table);
            }
        }
    }
</script>
{/literal}
