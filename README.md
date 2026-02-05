# Dispute Review Queue

A Rails 8 application for managing payment dispute workflows. This system ingests dispute events from payment providers via webhooks, provides a review interface for dispute management, and includes comprehensive reporting and audit logging.

## Features

### 🔔 Webhook Integration
- **Production-ready endpoint**: `POST /webhooks/disputes`
- **Idempotent processing**: Duplicate webhooks handled gracefully
- **Async job processing**: Sidekiq-powered background jobs
- **Raw payload storage**: Full traceability of all webhook events

### 👥 Role-Based Access Control
- **Admin**: Full access (Win/Loss, Submit Evidence, Reopen, Remove Evidence)
- **Reviewer**: Standard access (Win/Loss, Submit Evidence)
- **Read Only**: View-only access

### 📊 Reporting
- **Money Math**: Aggregate dispute volumes by currency and status
- **Time Zones**: Dispute activity across different time zones
- **Daily Volume**: Trend analysis
- **Time to Decision**: Performance metrics

### 📝 Audit Logging
- Tracks **who** did **what**, **when**, and **why**
- Logs all critical actions (login, logout, status changes, evidence uploads, reopens)
- Queryable via Rails console or database

### 🎯 Dispute Management
- Upload evidence with descriptions
- Submit evidence for review
- Resolve disputes (Win/Loss)
- Reopen closed disputes (Admin only)
- Remove evidence (Admin only)

---

## Tech Stack

- **Ruby**: 3.4.8
- **Rails**: 8.1.2
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq
- **File Storage**: Active Storage
- **Authentication**: bcrypt (has_secure_password)

---

## Getting Started

### Prerequisites

- Ruby 3.4.8
- PostgreSQL
- Redis (for Sidekiq)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dispute_queue
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Seed users** (optional, for testing)
   ```bash
   rails users:setup
   ```
   This creates:
   - Admin: `admin@example.com` / `password`
   - Reviewer: `reviewer@example.com` / `password`
   - Read-only: `readonly@example.com` / `password`

5. **Start Redis** (in a separate terminal)
   ```bash
   redis-server
   ```

6. **Start Sidekiq** (in a separate terminal)
   ```bash
   bundle exec sidekiq
   ```

7. **Start Rails server**
   ```bash
   rails server
   ```

8. **Visit the application**
   - App: http://localhost:3000
   - Sidekiq Dashboard: http://localhost:3000/sidekiq

---

## Usage

### Simulating Webhooks

Visit http://localhost:3000/webhooks/simulated/new and click "Trigger Webhook" to simulate a dispute event.

### Testing Webhook Endpoint

```bash
curl -X POST http://localhost:3000/webhooks/disputes \
  -H "Content-Type: application/json" \
  -d '{
    "id": "evt_test_001",
    "type": "charge.dispute.created",
    "data": {
      "object": {
        "id": "dp_test_001",
        "charge": "ch_test_001",
        "amount": 5000,
        "currency": "usd",
        "status": "needs_response"
      }
    }
  }'

  curl -X POST http://localhost:3000/webhooks/disputes \
  -H "Content-Type: application/json" \
  -d '{
    "id": "evt_test_001",
    "type": "charge.dispute.updated",
    "data": {
      "object": {
        "id": "dp_test_001",
        "charge": "ch_test_001",
        "amount": 5000,
        "currency": "usd",
        "status": "won"
      }
    }
  }'
```

### Viewing Audit Logs

```bash
rails console

# All logs
AuditLog.order(created_at: :desc).limit(10)

# Logs by user
AuditLog.where(user_id: 1)

# Logs by action
AuditLog.where(action: "dispute.reopen")

# Logs with reasons
AuditLog.where("details->>'reason' IS NOT NULL")

---

## Project Structure

app/
├── controllers/
│   ├── disputes_controller.rb       # Dispute management
│   ├── sessions_controller.rb       # Authentication
│   ├── reports_controller.rb        # Reporting dashboards
│   └── webhooks/
│       ├── disputes_controller.rb   # Webhook endpoint
│       └── simulated_controller.rb  # Webhook simulator
├── jobs/
│   └── dispute_ingestion_job.rb     # Async webhook processing
├── models/
│   ├── audit_log.rb                 # Audit trail
│   ├── charge.rb                    # Payment charges
│   ├── dispute.rb                   # Disputes (with AASM state machine)
│   ├── evidence.rb                  # Evidence attachments
│   ├── user.rb                      # Users with roles
│   └── webhook_event.rb             # Webhook event storage
└── views/
    ├── disputes/                    # Dispute UI
    ├── reports/                     # Reporting UI
    └── webhooks/                    # Webhook simulator UI
```

---

## API Documentation

### Webhook Endpoint

**Endpoint**: `POST /webhooks/disputes`

**Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "id": "evt_unique_id",
  "type": "charge.dispute.created",
  "data": {
    "object": {
      "id": "dp_dispute_id",
      "charge": "ch_charge_id",
      "amount": 5000,
      "currency": "usd",
      "status": "needs_response"
    }
  }
}
```

**Responses**:
- `200 OK`: Webhook received and queued
- `400 Bad Request`: Invalid JSON
- `422 Unprocessable Entity`: Missing required fields

**Event Types**:
- `charge.dispute.created`: New dispute
- `charge.dispute.updated`: Status change (won/lost)

---

## Database Schema

### Key Tables

- users: Authentication and roles
- charges: Payment transactions
- disputes: Dispute records (with AASM state machine)
- evidences: File attachments for disputes
- webhook_events: Raw webhook payloads
- audit_logs: Activity audit trail

---

## Deployment

This application is Docker-ready with Kamal support.

```bash
# Build and deploy
kamal deploy
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License.
