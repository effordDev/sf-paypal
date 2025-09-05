# Salesforce PayPal Integration

This repository provides an example Salesforce implementation for integrating with **PayPal Webhooks**.  
It includes an Apex REST service that listens for PayPal webhook events, verifies the signatures against PayPal’s API, and processes events within Salesforce.

---

## 🚀 Features
- **Webhook Listener**: Apex REST resource (`PaypalWebhookApi.cls`) to receive PayPal webhook calls.  
- **Signature Verification**: Validates incoming webhook requests with PayPal’s API to ensure authenticity.  
- **Extensible Framework**: Add your own logic to handle PayPal events (e.g., payment completed, subscription canceled).  
- **Salesforce Native**: 100% Apex-based solution, no external libraries required.  

---

## 📦 Project Structure
```
force-app/main/default/classes/
 ├── PaypalWebhookApi.cls
 ├── PaypalWebhookApi.cls-meta.xml
...
```

- `PaypalWebhookApi.cls` – REST endpoint for webhook handling.  
- Additional classes can be added for business logic, testing, and event mapping.

---

## ⚙️ Setup Instructions

1. **Clone this repository**:
   ```bash
   git clone https://github.com/<your-org>/sf-paypal-main.git
   cd sf-paypal-main
   ```

2. **Authenticate with Salesforce**:
   ```bash
   sf org login web --alias yourOrg
   ```

3. **Deploy the code**:
   ```bash
   sf project deploy start --source-dir force-app
   ```

4. **Configure Remote Site Settings** (if calling PayPal REST APIs):  
   - Add `https://api-m.sandbox.paypal.com` (Sandbox)  
   - Add `https://api-m.paypal.com` (Production)  

5. **Set Your Webhook ID**:  
   - Inside `PaypalWebhookApi.cls`, replace:  
     ```apex
     String webhookId = 'REPLACE_WITH_YOUR_WEBHOOK_ID';
     ```

6. **Expose the Endpoint**:  
   - Your webhook URL will look like:  
     ```
     https://<your-salesforce-domain>/services/apexrest/paypal/webhook
     ```

7. **Register Webhook in PayPal Developer Dashboard**:  
   - Go to [PayPal Developer Dashboard](https://developer.paypal.com/) → Webhooks.  
   - Add the Salesforce endpoint and select relevant events (e.g., `PAYMENT.SALE.COMPLETED`).  

---

## 🧪 Testing

- **Unit Tests**: Add Apex test classes to cover webhook flows (required for Salesforce deployments).  
- **Sandbox Testing**:  
  - Use PayPal Sandbox to send webhook events.  
  - Verify they are received and logged in Salesforce.  

---

## 📖 Resources
- [PayPal Webhooks Documentation](https://developer.paypal.com/docs/api/webhooks/)  
- [Salesforce Apex REST Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest.htm)  

---

## 🤝 Contributing
1. Fork the repo.  
2. Create a feature branch.  
3. Submit a PR with details of your changes.  

---

## 📜 License
This project is provided under the MIT License. See [LICENSE](LICENSE) for details.  
