
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

;; Validation functions
(define-private (is-valid-event-id (event-id uint))
  (is-some (map-get? events { event-id: event-id }))
)

(define-private (is-valid-ticket-id (ticket-id uint))
  (is-some (map-get? tickets { ticket-id: ticket-id }))
)

(define-private (is-event-organizer (event-id uint) (user principal))
  (match (map-get? events { event-id: event-id })
    event-data (is-eq (get organizer event-data) user)
    false
  )
)

(define-private (is-ticket-owner (ticket-id uint) (user principal))
  (match (map-get? tickets { ticket-id: ticket-id })
    ticket-data (is-eq (get owner ticket-data) user)
    false
  )
)

(define-private (is-admin (user principal))
  (match (map-get? user-roles { user: user })
    role-data (is-eq (get role role-data) ROLE-ADMIN)
    false
  )
)

(define-private (is-validator (event-id uint) (user principal))
  (match (map-get? event-validators { event-id: event-id, validator: user })
    validator-data (get authorized validator-data)
    false
  )
)

(define-private (is-contract-paused)
  (var-get contract-paused)
)

(define-private (is-event-active (event-id uint))
  (match (map-get? events { event-id: event-id })
    event-data (is-eq (get status event-data) EVENT-STATUS-ACTIVE)
    false
  )
)

(define-private (is-event-not-expired (event-id uint))
  (match (map-get? events { event-id: event-id })
    event-data (> (get start-time event-data) block-height)
    false
  )
)

(define-private (is-valid-ticket-type (ticket-type uint))
  (or 
    (is-eq ticket-type TICKET-TYPE-GENERAL)
    (or 
      (is-eq ticket-type TICKET-TYPE-VIP)
      (or 
        (is-eq ticket-type TICKET-TYPE-PREMIUM)
        (is-eq ticket-type TICKET-TYPE-BACKSTAGE)
      )
    )
  )
)

(define-private (is-valid-price (price uint))
  (and 
    (>= price MIN-TICKET-PRICE)
    (<= price MAX-TICKET-PRICE)
  )
)

(define-private (is-valid-capacity (capacity uint))
  (and 
    (> capacity u0)
    (<= capacity MAX-EVENT-CAPACITY)
  )
)

(define-private (is-valid-event-duration (start-time uint) (end-time uint))
  (let (
    (duration (- end-time start-time))
  )
    (and 
      (>= duration MIN-EVENT-DURATION)
      (<= duration MAX-EVENT-DURATION)
      (> start-time block-height)
    )
  )
)

;; Fee calculation functions
(define-private (calculate-platform-fee (amount uint))
  (/ (* amount PLATFORM-FEE-BPS) u10000)
)

(define-private (calculate-organizer-fee (amount uint))
  (/ (* amount ORGANIZER-FEE-BPS) u10000)
)

(define-private (calculate-refund-fee (amount uint))
  (/ (* amount REFUND-FEE-BPS) u10000)
)

(define-private (calculate-transfer-fee (amount uint))
  (/ (* amount TRANSFER-FEE-BPS) u10000)
)

(define-private (calculate-revenue-shares (gross-revenue uint))
  {
    artist-share: (/ (* gross-revenue ARTIST-SHARE-BPS) u10000),
    venue-share: (/ (* gross-revenue VENUE-SHARE-BPS) u10000),
    platform-share: (/ (* gross-revenue PLATFORM-SHARE-BPS) u10000)
  }
)

(define-private (calculate-net-amount-after-fees (gross-amount uint))
  (let (
    (platform-fee (calculate-platform-fee gross-amount))
    (organizer-fee (calculate-organizer-fee gross-amount))
  )
    (- gross-amount (+ platform-fee organizer-fee))
  )
)

;; QR code and verification functions
(define-private (generate-qr-code-hash (ticket-id uint) (timestamp uint))
  ;; Simple hash generation using available data
  (hash160 0x000000000000000000000000000000000000000000000000000000000000000000000000)
)

(define-private (is-valid-qr-code (qr-hash (buff 32)) (ticket-id uint))
  (match (map-get? ticket-verification { qr-code-hash: qr-hash })
    verification-data 
      (and 
        (is-eq (get ticket-id verification-data) ticket-id)
        (not (get used verification-data))
        (> (get expires-at verification-data) block-height)
      )
    false
  )
)

;; Ticket availability and capacity functions
(define-private (get-event-tickets-sold (event-id uint))
  (match (map-get? events { event-id: event-id })
    event-data (get tickets-sold event-data)
    u0
  )
)

(define-private (get-event-capacity (event-id uint))
  (match (map-get? events { event-id: event-id })
    event-data (get capacity event-data)
    u0
  )
)

(define-private (is-event-sold-out (event-id uint))
  (let (
    (tickets-sold (get-event-tickets-sold event-id))
    (capacity (get-event-capacity event-id))
  )
    (>= tickets-sold capacity)
  )
)

(define-private (get-ticket-type-sold (event-id uint) (ticket-type uint))
  (match (map-get? ticket-types { event-id: event-id, ticket-type: ticket-type })
    type-data (get sold type-data)
    u0
  )
)

(define-private (get-ticket-type-capacity (event-id uint) (ticket-type uint))
  (match (map-get? ticket-types { event-id: event-id, ticket-type: ticket-type })
    type-data (get capacity type-data)
    u0
  )
)

(define-private (is-ticket-type-sold-out (event-id uint) (ticket-type uint))
  (let (
    (sold (get-ticket-type-sold event-id ticket-type))
    (capacity (get-ticket-type-capacity event-id ticket-type))
  )
    (>= sold capacity)
  )
)

;; User limit checking functions
(define-private (get-user-ticket-count (user principal))
  (match (map-get? user-profiles { user: user })
    profile (get total-tickets-purchased profile)
    u0
  )
)

(define-private (can-user-purchase-tickets (user principal) (quantity uint))
  (let (
    (current-count (get-user-ticket-count user))
    (new-total (+ current-count quantity))
  )
    (<= new-total MAX-TICKETS-PER-USER)
  )
)

(define-private (get-organizer-event-count (organizer principal))
  (match (map-get? organizers { organizer: organizer })
    org-data (get events-created org-data)
    u0
  )
)

(define-private (can-organizer-create-event (organizer principal))
  (< (get-organizer-event-count organizer) MAX-EVENTS-PER-ORGANIZER)
)

;; Time and deadline functions
(define-private (is-within-refund-window (event-id uint))
  (match (map-get? events { event-id: event-id })
    event-data 
      (let (
        (refund-deadline (get refund-deadline event-data))
        (current-time block-height)
      )
        (> refund-deadline current-time)
      )
    false
  )
)

(define-private (calculate-refund-deadline (start-time uint))
  (- start-time REFUND-DEADLINE)
)

(define-private (is-sale-period-active (event-id uint) (ticket-type uint))
  (match (map-get? ticket-types { event-id: event-id, ticket-type: ticket-type })
    type-data 
      (let (
        (sale-start (get sale-start type-data))
        (sale-end (get sale-end type-data))
        (current-time block-height)
      )
        (and 
          (>= current-time sale-start)
          (<= current-time sale-end)
          (get enabled type-data)
        )
      )
    false
  )
)

;; String validation functions
(define-private (is-valid-string-length (str (string-ascii 500)) (max-length uint))
  (<= (len str) max-length)
)

(define-private (is-valid-event-name (name (string-ascii 100)))
  (and 
    (> (len name) u0)
    (is-valid-string-length name MAX-EVENT-NAME-LENGTH)
  )
)

(define-private (is-valid-event-description (description (string-ascii 500)))
  (is-valid-string-length description MAX-EVENT-DESCRIPTION-LENGTH)
)

(define-private (is-valid-venue-name (venue (string-ascii 100)))
  (and 
    (> (len venue) u0)
    (is-valid-string-length venue MAX-VENUE-NAME-LENGTH)
  )
)

;; Increment functions for IDs
(define-private (get-next-event-id)
  (let (
    (current-id (var-get next-event-id))
  )
    (var-set next-event-id (+ current-id u1))
    current-id
  )
)

(define-private (get-next-ticket-id)
  (let (
    (current-id (var-get next-ticket-id))
  )
    (var-set next-ticket-id (+ current-id u1))
    current-id
  )
)

;; Update functions for statistics
(define-private (increment-total-events)
  (var-set total-events-created (+ (var-get total-events-created) u1))
)

(define-private (increment-total-tickets-sold)
  (var-set total-tickets-sold (+ (var-get total-tickets-sold) u1))
)

(define-private (add-to-total-revenue (amount uint))
  (var-set total-revenue (+ (var-get total-revenue) amount))
)

;; Revenue distribution helper
(define-private (distribute-revenue (event-id uint) (amount uint))
  (let (
    (shares (calculate-revenue-shares amount))
    (current-revenue (unwrap-panic (map-get? event-revenue { event-id: event-id })))
  )
    (map-set event-revenue 
      { event-id: event-id }
      (merge current-revenue {
        gross-revenue: (+ (get gross-revenue current-revenue) amount),
        net-revenue: (+ (get net-revenue current-revenue) (get artist-share shares))
      })
    )
  )
)

;; Transfer helper functions
(define-private (create-transfer-record (ticket-id uint) (from principal) (to principal) (fee uint))
  (let (
    (transfer-id (+ (get-ticket-type-sold u0 u0) u1)) ;; Simple transfer ID generation
  )
    (map-set ticket-transfers
      { ticket-id: ticket-id, transfer-id: transfer-id }
      {
        from: from,
        to: to,
        transfer-time: block-height,
        transfer-fee: fee,
        reason: none
      }
    )
  )
)

;; Waitlist management helpers
(define-private (get-waitlist-position (event-id uint) (user principal))
  (match (map-get? event-waitlist { event-id: event-id, user: user })
    waitlist-data (get position waitlist-data)
    u0
  )
)

(define-private (add-to-waitlist (event-id uint) (user principal) (ticket-type-preference (optional uint)))
  (let (
    (position (+ (get-waitlist-position event-id user) u1))
  )
    (map-set event-waitlist
      { event-id: event-id, user: user }
      {
        joined-at: block-height,
        position: position,
        notified: false,
        ticket-type-preference: ticket-type-preference
      }
    )
  )
)

;; Reputation and scoring helpers
(define-private (update-user-reputation (user principal) (score-change int))
  (match (map-get? user-profiles { user: user })
    profile 
      (let (
        (current-score (get reputation-score profile))
        (new-score (+ current-score (if (> score-change 0) (to-uint score-change) u0)))
      )
        (map-set user-profiles
          { user: user }
          (merge profile { reputation-score: new-score })
        )
      )
    false
  )
)

(define-private (update-organizer-stats (organizer principal) (revenue-added uint))
  (match (map-get? organizers { organizer: organizer })
    org-data
      (map-set organizers
        { organizer: organizer }
        (merge org-data {
          total-revenue: (+ (get total-revenue org-data) revenue-added),
          events-created: (+ (get events-created org-data) u1)
        })
      )
    false
  )
)

;; public functions
;;
