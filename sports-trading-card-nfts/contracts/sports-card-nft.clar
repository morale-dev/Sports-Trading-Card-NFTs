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