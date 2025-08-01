;; Title: SocialCoin Community Rewards Protocol (SCRP)
;;
;; Summary: 
;; Revolutionary decentralized protocol enabling community-driven wealth redistribution
;; through automated reward mechanisms backed by cryptocurrency reserves.
;;
;; Description:
;; SocialCoin Community Rewards Protocol transforms how communities share prosperity
;; by creating a self-sustaining ecosystem where verified members receive periodic
;; rewards from a collectively funded treasury. The protocol features democratic
;; governance allowing participants to shape reward parameters, sophisticated 
;; verification systems preventing abuse, and emergency controls ensuring system
;; stability. Built for transparency and fairness, SCRP empowers communities to
;; create their own economic models while maintaining security and trust through
;; blockchain immutability.

;; CONSTANTS & CONFIGURATION

(define-constant contract-owner tx-sender)

;; Error codes for different failure scenarios
(define-constant err-owner-only (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-registered (err u102))
(define-constant err-ineligible (err u103))
(define-constant err-cooldown-active (err u104))
(define-constant err-insufficient-funds (err u105))
(define-constant err-invalid-amount (err u106))
(define-constant err-unauthorized (err u107))
(define-constant err-invalid-proposal (err u108))
(define-constant err-expired-proposal (err u109))
(define-constant err-invalid-value (err u110))

;; Protocol parameters
(define-constant distribution-interval u144) ;; ~1 day in blocks (10 min/block)
(define-constant minimum-balance u10000000) ;; Minimum treasury balance (10 STX)
(define-constant max-proposed-value u1000000000000) ;; Maximum value for governance proposals

;; STATE VARIABLES

(define-data-var treasury-balance uint u0) ;; Total funds available for distribution
(define-data-var total-participants uint u0) ;; Count of registered community members
(define-data-var distribution-amount uint u1000000) ;; Reward amount per claim (1 STX)
(define-data-var last-distribution-height uint u0) ;; Block height of last distribution
(define-data-var paused bool false) ;; Emergency pause state
(define-data-var proposal-counter uint u0) ;; Counter for governance proposals

;; DATA STRUCTURES

;; Community member profiles with claim history and verification status
(define-map participants
  principal
  {
    registered: bool, ;; Registration status
    last-claim-height: uint, ;; Block height of last reward claim
    total-claimed: uint, ;; Lifetime rewards received
    verification-status: bool, ;; Manual verification by contract owner
    join-height: uint, ;; Block height when user joined
    claims-count: uint, ;; Total number of successful claims
  }
)

;; Governance proposal tracking system
(define-map governance-proposals
  uint
  {
    proposer: principal, ;; Address that submitted proposal
    proposal-type: (string-ascii 32), ;; Type of parameter to modify
    proposed-value: uint, ;; New value being proposed
    votes-for: uint, ;; Number of supporting votes
    votes-against: uint, ;; Number of opposing votes
    status: (string-ascii 10), ;; Current proposal status
    expiry-height: uint, ;; Block height when voting ends
  }
)

;; Voting record to prevent double voting
(define-map voter-records
  {
    proposal-id: uint,
    voter: principal,
  }
  bool
)

;; PRIVATE HELPER FUNCTIONS

;; Verify if caller is the contract owner
(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner)
)

;; Check if user meets all eligibility criteria for reward claims
(define-private (is-eligible (user principal))
  (match (map-get? participants user)
    participant-info (and
      (get verification-status participant-info) ;; Must be verified
      (>= (- stacks-block-height (get last-claim-height participant-info))
        distribution-interval
      ) ;; Cooldown expired
      (>= (var-get treasury-balance) (var-get distribution-amount)) ;; Sufficient treasury funds
    )
    false
  )
)

;; Update participant record after successful reward claim
(define-private (update-participant-record
    (user principal)
    (claimed-amount uint)
  )
  (match (map-get? participants user)
    current-info (ok (map-set participants user
      (merge current-info {
        last-claim-height: stacks-block-height,
        total-claimed: (+ (get total-claimed current-info) claimed-amount),
        claims-count: (+ (get claims-count current-info) u1),
      })
    ))
    err-not-registered
  )
)

;; Validate governance proposal types
(define-private (is-valid-proposal-type (proposal-type (string-ascii 32)))
  (or
    (is-eq proposal-type "distribution-amount")
    (is-eq proposal-type "distribution-interval")
    (is-eq proposal-type "minimum-balance")
  )
)

;; Validate proposed values are within acceptable bounds
(define-private (is-valid-proposed-value (value uint))
  (and
    (> value u0)
    (<= value max-proposed-value)
  )
)

;; CORE PUBLIC FUNCTIONS

;; Register new community member
(define-public (register)
  (let ((existing-record (map-get? participants tx-sender)))
    (asserts! (is-none existing-record) err-already-registered)
    (map-set participants tx-sender {
      registered: true,
      last-claim-height: u0,
      total-claimed: u0,
      verification-status: false,
      join-height: stacks-block-height,
      claims-count: u0,
    })
    (var-set total-participants (+ (var-get total-participants) u1))
    (ok true)
  )
)

;; Verify participant eligibility (owner-only function)
(define-public (verify-participant (user principal))
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (asserts! (is-some (map-get? participants user)) err-not-registered)
    (map-set participants user
      (merge (unwrap! (map-get? participants user) err-not-registered) { verification-status: true })
    )
    (ok true)
  )
)

;; Claim periodic community rewards
(define-public (claim-ubi)
  (let (
      (user tx-sender)
      (can-claim (is-eligible user))
    )
    (asserts! (not (var-get paused)) err-unauthorized)
    (asserts! can-claim err-ineligible)
    (asserts! (>= (var-get treasury-balance) (var-get distribution-amount))
      err-insufficient-funds
    )
    ;; Transfer reward to claimant
    (try! (as-contract (stx-transfer? (var-get distribution-amount) contract-caller user)))
    (var-set treasury-balance
      (- (var-get treasury-balance) (var-get distribution-amount))
    )
    (try! (update-participant-record user (var-get distribution-amount)))
    (ok (var-get distribution-amount))
  )
)