@RestResource(urlMapping='/paypal/webhook')
global with sharing class PaypalWebhookApi {
    
    @HttpPost
    global static void doPost() {
        // 1) Read raw body (RestRequest has 'requestBody' Blob, not getBody())
        RestRequest req = RestContext.request;
        String body = req.requestBody == null ? '' : req.requestBody.toString();

        // 2) Grab PayPal verification headers
        String transmissionId   = req.headers.get('PAYPAL-TRANSMISSION-ID');
        String transmissionTime = req.headers.get('PAYPAL-TRANSMISSION-TIME');
        String certUrl          = req.headers.get('PAYPAL-CERT-URL');
        String authAlgo         = req.headers.get('PAYPAL-AUTH-ALGO');
        String transmissionSig  = req.headers.get('PAYPAL-TRANSMISSION-SIG');

        // 3) Your Webhook ID from PayPal app settings (Sandbox vs Live differ)
        String webhookId = 'REPLACE_WITH_YOUR_WEBHOOK_ID';

        // 4) Call PayPal to VERIFY the signature
        Map<String, Object> verifyReq = new Map<String, Object>{
            'auth_algo'         => authAlgo,
            'cert_url'          => certUrl,
            'transmission_id'   => transmissionId,
            'transmission_sig'  => transmissionSig,
            'transmission_time' => transmissionTime,
            'webhook_id'        => webhookId,
            'webhook_event'     => (Map<String,Object>) JSON.deserializeUntyped(body)
        };

        HttpRequest h = new HttpRequest();
        // NOTE: Make sure this Named Credential matches what you created
        h.setEndpoint('callout:PayPal_Sandbox/v1/notifications/verify-webhook-signature'); // use _LIVE in prod
        h.setMethod('POST');
        h.setHeader('Content-Type','application/json');
        h.setBody(JSON.serialize(verifyReq));

        HttpResponse r = new Http().send(h);

        Map<String,Object> verifyRes = (Map<String,Object>) JSON.deserializeUntyped(r.getBody());
        Boolean verified = 'SUCCESS'.equalsIgnoreCase((String) verifyRes.get('verification_status'));

        if (!verified) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Invalid signature');
            return;
        }

        // 5) Safe to trust. Parse event and handle idempotently
        Map<String,Object> evt = (Map<String,Object>) JSON.deserializeUntyped(body);
        String eventId   = (String) evt.get('id');
        String eventType = (String) evt.get('event_type');

        // Idempotency guard (implement these helpers in your org)
        // if (isAlreadyProcessed(eventId)) {
        //     RestContext.response.statusCode = 200;
        //     return;
        // }

        if (eventType == 'PAYMENT.CAPTURE.COMPLETED') {
            Map<String,Object> resource = (Map<String,Object>) evt.get('resource');
            String captureId = (String) resource.get('id');
            // Update your Payment__c etc.
            // applyCapture(resource);
        } else if (eventType == 'CHECKOUT.ORDER.APPROVED') {
            // Optional: mark Payment__c as Approved
        }

        //todo: mark order processed
        RestContext.response.statusCode = 200;
    }
}
