
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
;;

;; private functions
;;

;; public functions
;;
