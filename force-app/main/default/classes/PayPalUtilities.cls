public with sharing class PayPalUtilities {
    
    /* 
    * Test Cards
    Visa → 4111111111111111
    Mastercard → 5555555555554444
    Amex → 378282246310005
    */
    public static void getPayPalToken() {
        HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Paypal_Sandbox/v1/oauth2/token'); // your Named Credential
            req.setMethod('POST');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setBody('grant_type=client_credentials');

        HttpResponse res = new Http().send(req);

        Map<String,Object> j = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        String token = (String) j.get('access_token');
        String type  = (String) j.get('token_type');
        Object exp   = j.get('expires_in');

        System.debug('Got token? ' + (token != null));
        System.debug('Type: ' + type + ', ExpiresIn: ' + exp);

        // If you really need to see it, only log a snippet:
        System.debug('Token prefix: ' + (token != null ? token.substring(0, 12) + '...' : 'null'));
    }

    //creates a payment order and logs the response
    public static void createPaymentOrder() {
        HttpRequest r = new HttpRequest();
        r.setEndpoint('callout:PayPal_Sandbox/v2/checkout/orders'); // your sandbox Named Credential
        r.setMethod('POST');
        r.setHeader('Content-Type','application/json');
        r.setBody(JSON.serialize(new Map<String,Object>{
        'intent' => 'CAPTURE',
        'purchase_units' => new List<Object>{
            new Map<String,Object>{
            'amount' => new Map<String,Object>{ 'currency_code' => 'USD', 'value' => '10.00' }
            }
        },
        'application_context' => new Map<String,Object>{
            'return_url' => URL.getOrgDomainUrl().toExternalForm() + '/s/paypal-return',
            'cancel_url' => URL.getOrgDomainUrl().toExternalForm() + '/s/paypal-cancel',
            'user_action' => 'PAY_NOW',
            'shipping_preference' => 'NO_SHIPPING'
        }
        }));
        HttpResponse rr = new Http().send(r);
        System.debug(rr.getBody()); // copy id and the "approve" link
    }

    //captures payment for an order previously created - moves the money
    public static void captureOrder(String orderId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:PayPal_Sandbox/v2/checkout/orders/' 
                        + EncodingUtil.urlEncode(orderId, 'UTF-8') 
                        + '/capture');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setBody('{}');

        HttpResponse res = new Http().send(req);

        System.debug('Status: ' + res.getStatus() + ' ' + res.getStatusCode());
        System.debug('Body: ' + res.getBody());

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            Map<String,Object> payload = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            String status = (String) payload.get('status');
            if (status == 'COMPLETED') {
                // Pull capture id
                List<Object> pus = (List<Object>) payload.get('purchase_units');
                if (!pus.isEmpty()) {
                    Map<String,Object> pu = (Map<String,Object>) pus[0];
                    Map<String,Object> payments = (Map<String,Object>) pu.get('payments');
                    if (payments != null) {
                        List<Object> captures = (List<Object>) payments.get('captures');
                        if (!captures.isEmpty()) {
                            String captureId = (String) ((Map<String,Object>)captures[0]).get('id');
                            System.debug('✅ Capture successful, id=' + captureId);
                            // TODO: update Payment__c in Salesforce
                        }
                    }
                }
            } else {
                System.debug('⚠️ Capture not completed. Status=' + status);
            }
        } else {
            throw new CalloutException('PayPal capture failed: ' 
                                    + res.getStatus() + ' ' + res.getBody());
        }
    }

}