;; Sports Trading Card NFT Contract
;; NFT contract for digital sports trading cards with player stats and rarity

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token sports-card uint)

;; Contract State Variables
(define-data-var last-token-id uint u0)
(define-data-var contract-owner principal tx-sender)
(define-data-var base-uri (string-ascii 256) "https://api.sportscards.stacks/cards/")

;; Data Maps
(define-map card-info uint {
    player-name: (string-ascii 50),
    team: (string-ascii 30),
    position: (string-ascii 20),
    jersey-number: uint,
    season: uint,
    rarity: uint,
    card-series: (string-ascii 30)
})

(define-map player-stats uint {
    games-played: uint,
    points-avg: uint,
    assists-avg: uint,
    rebounds-avg: uint,
    field-goal-pct: uint
})

;; Error Constants
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-INVALID-PARAMS (err u400))
(define-constant ERR-INVALID-RARITY (err u402))

;; Rarity Constants
(define-constant RARITY-COMMON u1)
(define-constant RARITY-UNCOMMON u2)
(define-constant RARITY-RARE u3)
(define-constant RARITY-LEGENDARY u4)

;; Basic Read-Only Functions
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (var-get base-uri) (uint-to-ascii token-id))))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? sports-card token-id))
)

(define-read-only (get-card-info (token-id uint))
    (map-get? card-info token-id)
)

(define-read-only (get-player-stats (token-id uint))
    (map-get? player-stats token-id)
)

(define-read-only (get-rarity-name (rarity uint))
    (if (is-eq rarity RARITY-COMMON)
        (ok "Common")
        (if (is-eq rarity RARITY-UNCOMMON)
            (ok "Uncommon")
            (if (is-eq rarity RARITY-RARE)
                (ok "Rare")
                (if (is-eq rarity RARITY-LEGENDARY)
                    (ok "Legendary")
                    (err u404)
                )
            )
        )
    )
)

;; Core Public Functions

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
        (asserts! (is-some (nft-get-owner? sports-card token-id)) ERR-NOT-FOUND)
        (nft-transfer? sports-card token-id sender recipient)
    )
)

(define-public (mint-sports-card
    (recipient principal)
    (player-name (string-ascii 50))
    (team (string-ascii 30))
    (position (string-ascii 20))
    (jersey-number uint)
    (season uint)
    (rarity uint)
    (card-series (string-ascii 30))
    (games-played uint)
    (points-avg uint)
    (assists-avg uint)
    (rebounds-avg uint)
    (field-goal-pct uint)
)
    (let
        (
            (next-id (+ (var-get last-token-id) u1))
        )
        ;; Validation checks
        (asserts! (and (>= rarity RARITY-COMMON) (<= rarity RARITY-LEGENDARY)) ERR-INVALID-RARITY)
        (asserts! (> season u2000) ERR-INVALID-PARAMS)
        (asserts! (<= jersey-number u99) ERR-INVALID-PARAMS)
        (asserts! (<= field-goal-pct u100) ERR-INVALID-PARAMS)
        
        ;; Mint the NFT
        (try! (nft-mint? sports-card next-id recipient))
        
        ;; Store card information
        (map-set card-info next-id {
            player-name: player-name,
            team: team,
            position: position,
            jersey-number: jersey-number,
            season: season,
            rarity: rarity,
            card-series: card-series
        })
        
        ;; Store player statistics
        (map-set player-stats next-id {
            games-played: games-played,
            points-avg: points-avg,
            assists-avg: assists-avg,
            rebounds-avg: rebounds-avg,
            field-goal-pct: field-goal-pct
        })
        
        ;; Update token counter
        (var-set last-token-id next-id)
        (ok next-id)
    )
)

(define-public (update-base-uri (new-uri (string-ascii 256)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (var-set base-uri new-uri)
        (ok true)
    )
)