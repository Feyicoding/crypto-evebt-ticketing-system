# 🎫 Crypto Event Ticketing System

A decentralized event ticketing platform built on the Stacks blockchain using Clarity smart contracts. This system provides secure, transparent, and fraud-resistant ticket management with multi-tier pricing, revenue sharing, and comprehensive event operations.

![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange)
![Clarity](https://img.shields.io/badge/Language-Clarity-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen)

## 🌟 Features

### 🎪 **Event Management**
- **Event Creation**: Comprehensive event setup with venues, timing, and capacity
- **Multi-tier Ticketing**: Support for General, VIP, Premium, and Backstage tickets
- **Dynamic Pricing**: Configurable pricing per ticket type with sale periods
- **Event Lifecycle**: Created → Active → Completed status management

### 🎫 **Ticket Operations**
- **Secure Purchasing**: STX-based payment processing with automatic fee calculation
- **QR Code Validation**: Anti-fraud ticket verification system
- **Peer-to-peer Transfers**: Secure ticket transfers between users
- **Refund System**: Request-based refund process with admin approval

### 💰 **Financial Management**
- **Revenue Sharing**: Configurable splits (Artist 70%, Venue 20%, Platform 10%)
- **Fee Structure**: Platform (2.5%), Organizer (5%), Refund (1%), Transfer (0.5%)
- **Automatic Payments**: STX transfers with fee deduction
- **Complete Audit Trail**: Transparent financial tracking

### 🔐 **Security & Access Control**
- **Role-based Permissions**: Admin, Organizer, User, Validator roles
- **Input Validation**: Comprehensive data sanitization and business rule enforcement
- **Emergency Controls**: Contract pause functionality for crisis management
- **Anti-fraud Measures**: QR code validation and ownership verification

### 📊 **Analytics & Reporting**
- **User Profiles**: Reputation scoring and purchase history
- **Event Analytics**: Attendance tracking and revenue reporting
- **Global Statistics**: Platform-wide metrics and insights
- **Audit Trails**: Complete transaction history

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development tool
- [Node.js](https://nodejs.org/) (for testing)
- [Stacks Wallet](https://www.hiro.so/wallet) (for interaction)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/crypto-event-ticketing-system.git
   cd crypto-event-ticketing-system
   ```

2. **Install Clarinet** (if not already installed)
   ```bash
   # macOS
   brew install clarinet
   
   # Ubuntu/Debian
   wget -nv https://github.com/hirosystems/clarinet/releases/download/v1.5.4/clarinet-linux-x64-glibc.tar.gz -O clarinet-linux-x64.tar.gz
   tar -xf clarinet-linux-x64.tar.gz
   chmod +x ./clarinet
   sudo mv ./clarinet /usr/local/bin
   ```

3. **Verify installation**
   ```bash
   clarinet --version
   ```

### Development

1. **Check contract syntax**
   ```bash
   clarinet check
   ```

2. **Run tests**
   ```bash
   clarinet test
   ```

3. **Deploy to local network**
   ```bash
   clarinet integrate
   ```

## 📖 Usage Guide

### For Event Organizers

#### 1. Create an Event
```clarity
(contract-call? .crypto-event-ticketing-system create-event
  "Rock Concert 2025"           ;; name
  "Amazing rock concert"        ;; description  
  "Madison Square Garden"       ;; venue
  u2000000                     ;; start-time (block height)
  u2000100                     ;; end-time
  u10000                       ;; capacity
  u5000000                     ;; base-price (5 STX in microSTX)
  true                         ;; refund-enabled
  true                         ;; transfer-enabled
  none                         ;; metadata-uri
)
```

#### 2. Configure Ticket Types
```clarity
(contract-call? .crypto-event-ticketing-system configure-ticket-type
  u1                           ;; event-id
  u1                           ;; ticket-type (VIP)
  "VIP Access"                 ;; name
  u10000000                    ;; price (10 STX)
  u100                         ;; capacity
  u1900000                     ;; sale-start
  u1999999                     ;; sale-end
)
```

#### 3. Activate Event
```clarity
(contract-call? .crypto-event-ticketing-system activate-event u1)
```

### For Ticket Buyers

#### 1. Purchase Ticket
```clarity
(contract-call? .crypto-event-ticketing-system purchase-ticket
  u1                           ;; event-id
  u0                           ;; ticket-type (General)
)
```

#### 2. Transfer Ticket
```clarity
(contract-call? .crypto-event-ticketing-system transfer-ticket
  u1                           ;; ticket-id
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7  ;; to-principal
)
```

#### 3. Request Refund
```clarity
(contract-call? .crypto-event-ticketing-system request-refund u1)
```

### For Event Staff

#### Validate Ticket at Entry
```clarity
(contract-call? .crypto-event-ticketing-system validate-ticket
  u1                           ;; ticket-id
  0x1234567890abcdef...        ;; qr-hash
)
```

## 🏗️ Architecture

### Smart Contract Structure

```
crypto-event-ticketing-system.clar
├── Constants (80+)
│   ├── Error codes (18)
│   ├── Status constants
│   ├── System limits
│   ├── Fee structures
│   └── Revenue sharing
├── Data Maps (20+)
│   ├── Events
│   ├── Tickets
│   ├── Users
│   ├── Revenue tracking
│   └── Administrative data
├── Private Functions (40+)
│   ├── Validation functions
│   ├── Fee calculations
│   ├── Capacity management
│   └── Business logic helpers
└── Public Functions (20+)
    ├── Event management
    ├── Ticket operations
    ├── Administrative functions
    └── Read-only functions
```

### Key Data Structures

#### Events
```clarity
{
  organizer: principal,
  name: (string-ascii 100),
  description: (string-ascii 500),
  venue: (string-ascii 100),
  start-time: uint,
  end-time: uint,
  capacity: uint,
  tickets-sold: uint,
  status: uint,
  base-price: uint,
  refund-enabled: bool,
  transfer-enabled: bool,
  // ... additional fields
}
```

#### Tickets
```clarity
{
  event-id: uint,
  ticket-type: uint,
  owner: principal,
  original-buyer: principal,
  purchase-price: uint,
  status: uint,
  qr-code-hash: (buff 32),
  // ... additional fields
}
```

## 🧪 Testing

### Running Tests
```bash
# Check contract syntax
clarinet check

# Run all tests
clarinet test

# Run specific test file
clarinet test tests/crypto-event-ticketing-system_test.ts
```

### Test Coverage

The test suite covers:
- ✅ Event creation and management
- ✅ Ticket purchasing and validation
- ✅ Transfer operations
- ✅ Refund processes
- ✅ Administrative functions
- ✅ Error handling
- ✅ Edge cases

## 🌍 Deployment

### Local Development
```bash
clarinet integrate
```

### Testnet Deployment
```bash
clarinet publish --testnet
```

### Mainnet Deployment
```bash
clarinet publish --mainnet
```

## 📊 Business Model

### Fee Structure
- **Platform Fee**: 2.5% of ticket price
- **Organizer Fee**: 5% of ticket price
- **Refund Fee**: 1% of ticket price
- **Transfer Fee**: 0.5% of ticket price

### Revenue Sharing
- **Artists**: 70% of gross revenue
- **Venues**: 20% of gross revenue
- **Platform**: 10% of gross revenue

### System Limits
- **Max Events per Organizer**: 100
- **Max Tickets per Event**: 10,000
- **Max Tickets per User**: 50
- **Price Range**: 1 STX - 1M STX
- **Event Capacity**: 1 - 100,000

## 🛡️ Security

### Access Control
- **Role-based Permissions**: 4-tier authorization system
- **Owner Verification**: Cryptographic proof of ownership
- **Admin Controls**: Emergency pause and recovery functions

### Anti-fraud Measures
- **QR Code Validation**: Unique, time-limited verification codes
- **Double-spending Prevention**: Atomic ticket status updates
- **Capacity Enforcement**: Strict sold-out protection

### Input Validation
- **Parameter Sanitization**: All inputs validated
- **Business Rule Enforcement**: Price, capacity, and time limits
- **Error Handling**: Comprehensive error codes and messages

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature-name`
3. **Make your changes**: Follow the coding standards
4. **Add tests**: Ensure your code is tested
5. **Commit changes**: `git commit -m 'Add feature'`
6. **Push to branch**: `git push origin feature-name`
7. **Submit a pull request**

### Development Guidelines

- Follow Clarity best practices
- Add comprehensive tests for new features
- Update documentation for API changes
- Ensure all tests pass before submitting

## 📝 API Reference

### Public Functions

#### Event Management
- `create-event` - Create a new event
- `configure-ticket-type` - Set up ticket categories
- `activate-event` - Enable ticket sales

#### Ticket Operations
- `purchase-ticket` - Buy a ticket
- `transfer-ticket` - Transfer ownership
- `request-refund` - Request ticket refund

#### Administrative
- `add-event-validator` - Authorize validators
- `approve-refund` - Process refund requests
- `set-contract-pause` - Emergency controls
- `set-user-role` - Role management

#### Read-only Functions
- `get-event` - Event details
- `get-ticket` - Ticket information
- `get-user-profile` - User statistics
- `owns-ticket` - Ownership verification
- `get-contract-stats` - Platform metrics

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | ERR-NOT-AUTHORIZED | Insufficient permissions |
| u101 | ERR-EVENT-NOT-FOUND | Event doesn't exist |
| u102 | ERR-TICKET-NOT-FOUND | Ticket doesn't exist |
| u103 | ERR-INSUFFICIENT-FUNDS | Not enough STX |
| u104 | ERR-EVENT-SOLD-OUT | No tickets available |
| u105 | ERR-EVENT-NOT-ACTIVE | Event not in active status |
| ... | ... | ... |

## 🔗 Resources

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity/)
- [Clarinet Documentation](https://github.com/hirosystems/clarinet)
- [Stacks Explorer](https://explorer.stacks.co/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Stacks Foundation for the blockchain infrastructure
- Hiro Systems for development tools
- Community contributors and testers

## 📞 Support

- **Documentation**: Check this README and inline code comments
- **Issues**: Submit GitHub issues for bugs or feature requests
- **Community**: Join the Stacks Discord for discussions
- **Contact**: Reach out to the development team

---

**Built with ❤️ on Stacks Blockchain**

*Empowering transparent, secure, and decentralized event ticketing for the future.*
