
;; crypto-event-ticketing-system
;; A decentralized event ticketing system on the Stacks blockchain
;; Enables secure ticket creation, purchase, transfer, and validation

;; constants

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-EVENT-NOT-FOUND (err u101))
(define-constant ERR-TICKET-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-EVENT-SOLD-OUT (err u104))
(define-constant ERR-EVENT-NOT-ACTIVE (err u105))
(define-constant ERR-EVENT-EXPIRED (err u106))
(define-constant ERR-TICKET-ALREADY-USED (err u107))
(define-constant ERR-INVALID-TICKET-TYPE (err u108))
(define-constant ERR-TRANSFER-NOT-ALLOWED (err u109))
(define-constant ERR-REFUND-NOT-ALLOWED (err u110))
(define-constant ERR-EVENT-CANCELLED (err u111))
(define-constant ERR-INVALID-PRICE (err u112))
(define-constant ERR-INVALID-CAPACITY (err u113))
(define-constant ERR-INVALID-DATE (err u114))
(define-constant ERR-DUPLICATE-EVENT (err u115))
(define-constant ERR-TICKET-LIMIT-EXCEEDED (err u116))
(define-constant ERR-VERIFICATION-FAILED (err u117))

;; Event status constants
(define-constant EVENT-STATUS-CREATED u0)
(define-constant EVENT-STATUS-ACTIVE u1)
(define-constant EVENT-STATUS-PAUSED u2)
(define-constant EVENT-STATUS-CANCELLED u3)
(define-constant EVENT-STATUS-COMPLETED u4)

;; Ticket type constants
(define-constant TICKET-TYPE-GENERAL u0)
(define-constant TICKET-TYPE-VIP u1)
(define-constant TICKET-TYPE-PREMIUM u2)
(define-constant TICKET-TYPE-BACKSTAGE u3)

;; Ticket status constants
(define-constant TICKET-STATUS-AVAILABLE u0)
(define-constant TICKET-STATUS-SOLD u1)
(define-constant TICKET-STATUS-USED u2)
(define-constant TICKET-STATUS-REFUNDED u3)
(define-constant TICKET-STATUS-TRANSFERRED u4)

;; System limits
(define-constant MAX-EVENTS-PER-ORGANIZER u100)
(define-constant MAX-TICKETS-PER-EVENT u10000)
(define-constant MAX-TICKETS-PER-USER u50)
(define-constant MIN-TICKET-PRICE u1000000) ;; 1 STX in microSTX
(define-constant MAX-TICKET-PRICE u1000000000000) ;; 1M STX in microSTX
(define-constant MAX-EVENT-CAPACITY u100000)
(define-constant MIN-EVENT-DURATION u3600) ;; 1 hour in seconds
(define-constant MAX-EVENT-DURATION u2592000) ;; 30 days in seconds

;; Commission and fees (in basis points - 100 = 1%)
(define-constant PLATFORM-FEE-BPS u250) ;; 2.5%
(define-constant ORGANIZER-FEE-BPS u500) ;; 5%
(define-constant REFUND-FEE-BPS u100) ;; 1%
(define-constant TRANSFER-FEE-BPS u50) ;; 0.5%

;; Time constants (in seconds)
(define-constant SECONDS-PER-MINUTE u60)
(define-constant SECONDS-PER-HOUR u3600)
(define-constant SECONDS-PER-DAY u86400)
(define-constant SECONDS-PER-WEEK u604800)
(define-constant REFUND-DEADLINE u86400) ;; 24 hours before event

;; String length limits
(define-constant MAX-EVENT-NAME-LENGTH u100)
(define-constant MAX-EVENT-DESCRIPTION-LENGTH u500)
(define-constant MAX-VENUE-NAME-LENGTH u100)
(define-constant MAX-ORGANIZER-NAME-LENGTH u50)

;; Default values
(define-constant DEFAULT-TICKET-LIMIT-PER-USER u10)
(define-constant DEFAULT-REFUND-WINDOW u604800) ;; 7 days
(define-constant DEFAULT-TRANSFER-ENABLED true)

;; Contract owner (can be updated via governance)
(define-constant CONTRACT-OWNER tx-sender)

;; Version and metadata
(define-constant CONTRACT-VERSION u1)
(define-constant CONTRACT-NAME "crypto-event-ticketing-system")

;; Role-based access constants
(define-constant ROLE-ADMIN u0)
(define-constant ROLE-ORGANIZER u1)
(define-constant ROLE-USER u2)
(define-constant ROLE-VALIDATOR u3)

;; Validation constants
(define-constant TICKET-ID-PREFIX "TKT")
(define-constant EVENT-ID-PREFIX "EVT")
(define-constant QR-CODE-LENGTH u32)

;; Revenue sharing constants (in basis points)
(define-constant ARTIST-SHARE-BPS u7000) ;; 70%
(define-constant VENUE-SHARE-BPS u2000) ;; 20%
(define-constant PLATFORM-SHARE-BPS u1000) ;; 10%

;; data maps and vars

;; Global variables
(define-data-var next-event-id uint u1)
(define-data-var next-ticket-id uint u1)
(define-data-var contract-paused bool false)
(define-data-var platform-fee-recipient principal CONTRACT-OWNER)
(define-data-var total-events-created uint u0)
(define-data-var total-tickets-sold uint u0)
(define-data-var total-revenue uint u0)

;; Event data structure
(define-map events
  { event-id: uint }
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
    created-at: uint,
    updated-at: uint,
    base-price: uint,
    refund-enabled: bool,
    transfer-enabled: bool,
    refund-deadline: uint,
    metadata-uri: (optional (string-ascii 200))
  }
)

;; Ticket type configurations per event
(define-map ticket-types
  { event-id: uint, ticket-type: uint }
  {
    name: (string-ascii 50),
    price: uint,
    capacity: uint,
    sold: uint,
    sale-start: uint,
    sale-end: uint,
    enabled: bool,
    metadata: (optional (string-ascii 200))
  }
)

;; Individual ticket data
(define-map tickets
  { ticket-id: uint }
  {
    event-id: uint,
    ticket-type: uint,
    owner: principal,
    original-buyer: principal,
    purchase-price: uint,
    purchase-time: uint,
    status: uint,
    used-at: (optional uint),
    qr-code-hash: (buff 32),
    seat-number: (optional (string-ascii 20)),
    metadata: (optional (string-ascii 200))
  }
)

;; User profiles and stats
(define-map user-profiles
  { user: principal }
  {
    name: (optional (string-ascii 50)),
    email-hash: (optional (buff 32)),
    total-tickets-purchased: uint,
    total-events-attended: uint,
    reputation-score: uint,
    created-at: uint,
    last-activity: uint,
    verified: bool
  }
)

;; User ticket ownership tracking
(define-map user-tickets
  { user: principal, ticket-id: uint }
  { owned: bool }
)

;; Event organizer data
(define-map organizers
  { organizer: principal }
  {
    name: (string-ascii 50),
    verified: bool,
    events-created: uint,
    total-revenue: uint,
    reputation-score: uint,
    created-at: uint,
    contact-info: (optional (string-ascii 100)),
    website: (optional (string-ascii 100))
  }
)

;; Event attendance tracking
(define-map event-attendance
  { event-id: uint, user: principal }
  {
    attended: bool,
    check-in-time: (optional uint),
    check-out-time: (optional uint),
    validator: (optional principal)
  }
)

;; Ticket transfer history
(define-map ticket-transfers
  { ticket-id: uint, transfer-id: uint }
  {
    from: principal,
    to: principal,
    transfer-time: uint,
    transfer-fee: uint,
    reason: (optional (string-ascii 100))
  }
)

;; Refund requests and processing
(define-map refund-requests
  { ticket-id: uint }
  {
    requester: principal,
    request-time: uint,
    reason: (string-ascii 200),
    status: uint, ;; 0: pending, 1: approved, 2: rejected, 3: processed
    processed-at: (optional uint),
    refund-amount: uint,
    admin-notes: (optional (string-ascii 200))
  }
)

;; Revenue tracking per event
(define-map event-revenue
  { event-id: uint }
  {
    gross-revenue: uint,
    platform-fees: uint,
    organizer-fees: uint,
    net-revenue: uint,
    refunds-issued: uint,
    transfers-revenue: uint
  }
)

;; Admin and validator roles
(define-map user-roles
  { user: principal }
  { role: uint }
)

;; Event validation and check-in validators
(define-map event-validators
  { event-id: uint, validator: principal }
  { authorized: bool, added-at: uint }
)

;; Ticket verification codes (for QR code validation)
(define-map ticket-verification
  { qr-code-hash: (buff 32) }
  {
    ticket-id: uint,
    generated-at: uint,
    expires-at: uint,
    used: bool
  }
)

;; Event categories and tags
(define-map event-categories
  { event-id: uint, category: (string-ascii 30) }
  { assigned: bool }
)

;; Waitlist for sold-out events
(define-map event-waitlist
  { event-id: uint, user: principal }
  {
    joined-at: uint,
    position: uint,
    notified: bool,
    ticket-type-preference: (optional uint)
  }
)

;; Pricing tiers and dynamic pricing
(define-map pricing-tiers
  { event-id: uint, tier: uint }
  {
    tier-name: (string-ascii 30),
    base-price: uint,
    price-multiplier: uint, ;; basis points
    capacity-threshold: uint,
    active: bool
  }
)

;; Event reviews and ratings
(define-map event-reviews
  { event-id: uint, reviewer: principal }
  {
    rating: uint, ;; 1-5 stars
    review-text: (optional (string-ascii 300)),
    reviewed-at: uint,
    verified-attendee: bool
  }
)

;; System configuration and settings
(define-map system-config
  { key: (string-ascii 30) }
  { value: (string-ascii 100) }
)

;; Emergency pause functionality per event
(define-map event-emergency-status
  { event-id: uint }
  {
    paused: bool,
    paused-at: (optional uint),
    paused-by: (optional principal),
    reason: (optional (string-ascii 200))
  }
)

;; Ticket resale marketplace
(define-map ticket-resale
  { ticket-id: uint }
  {
    seller: principal,
    asking-price: uint,
    listed-at: uint,
    expires-at: uint,
    sold: bool,
    buyer: (optional principal),
    platform-fee: uint
  }
)

;; private functions
;;

;; public functions
;;
