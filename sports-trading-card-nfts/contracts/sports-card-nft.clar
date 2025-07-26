;; Sports Trading Card NFT Contract
;; NFT contract for digital sports trading cards with player stats and rarity

(define-non-fungible-token sports-card uint)

(define-data-var last-token-id uint u0)
(define-data-var contract-owner principal tx-sender)
(define-data-var base-uri (string-ascii 256) "https://api.sportscards.stacks/cards/")

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

(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-INVALID-PARAMS (err u400))
(define-constant ERR-INVALID-RARITY (err u402))

(define-constant RARITY-COMMON u1)
(define-constant RARITY-UNCOMMON u2)
(define-constant RARITY-RARE u3)
(define-constant RARITY-LEGENDARY u4)

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
        (asserts! (and (>= rarity RARITY-COMMON) (<= rarity RARITY-LEGENDARY)) ERR-INVALID-RARITY)
        (asserts! (> season u2000) ERR-INVALID-PARAMS)
        (asserts! (<= jersey-number u99) ERR-INVALID-PARAMS)
        (asserts! (<= field-goal-pct u100) ERR-INVALID-PARAMS)
        
        (try! (nft-mint? sports-card next-id recipient))
        
        (map-set card-info next-id {
            player-name: player-name,
            team: team,
            position: position,
            jersey-number: jersey-number,
            season: season,
            rarity: rarity,
            card-series: card-series
        })
        
        (map-set player-stats next-id {
            games-played: games-played,
            points-avg: points-avg,
            assists-avg: assists-avg,
            rebounds-avg: rebounds-avg,
            field-goal-pct: field-goal-pct
        })
        
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

;; Get all cards owned by a specific address
(define-read-only (get-cards-by-owner (owner principal))
    (let
        (
            (total-cards (var-get last-token-id))
        )
        (filter is-owned-by-user (generate-token-list total-cards))
    )
)

;; Helper function for get-cards-by-owner
(define-private (is-owned-by-user (token-info {token-id: uint, owner: (optional principal), card-info: (optional {player-name: (string-ascii 50), team: (string-ascii 30), position: (string-ascii 20), jersey-number: uint, season: uint, rarity: uint, card-series: (string-ascii 30)})}))
    (match (get owner token-info)
        owner-principal (is-eq owner-principal tx-sender)
        false
    )
)

;; Helper function to get token info
(define-private (get-token-info (token-id uint))
    {
        token-id: token-id,
        owner: (nft-get-owner? sports-card token-id),
        card-info: (map-get? card-info token-id)
    }
)

;; Helper function to generate list of token info up to n tokens
(define-private (generate-token-list (n uint))
    (map get-token-info (generate-uint-list n))
)

;; Helper function to generate list of uints from 1 to n (simplified version)
(define-private (generate-uint-list (n uint))
    (if (<= n u0)
        (list)
        (if (<= n u20)
            (unwrap-panic (slice? (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20) u0 n))
            ;; For larger numbers, we'll need to handle differently
            (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20)
        )
    )
)

;; Burn a card (remove from circulation)
(define-public (burn-card (token-id uint))
    (let
        (
            (current-owner (unwrap! (nft-get-owner? sports-card token-id) ERR-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender current-owner) ERR-NOT-AUTHORIZED)
        
        ;; Remove card data from maps
        (map-delete card-info token-id)
        (map-delete player-stats token-id)
        
        ;; Burn the NFT
        (nft-burn? sports-card token-id current-owner)
    )
)

(define-read-only (calculate-card-value (token-id uint))
    (match (get-card-info token-id)
        card-data
        (match (get-player-stats token-id)
            stats-data
            (let
                (
                    (base-value u100)
                    (rarity-multiplier (get rarity card-data))
                    (performance-bonus (+ (get points-avg stats-data) (get assists-avg stats-data)))
                )
                (ok (+ (* base-value rarity-multiplier) performance-bonus))
            )
            (err ERR-NOT-FOUND)
        )
        (err ERR-NOT-FOUND)
    )
)

;; Simplified uint-to-ascii function for basic conversion
(define-read-only (uint-to-ascii (value uint))
    (if (<= value u9)
        (unwrap-panic (element-at "0123456789" value))
        (if (<= value u99)
            (concat 
                (unwrap-panic (element-at "0123456789" (/ value u10)))
                (unwrap-panic (element-at "0123456789" (mod value u10)))
            )
            (if (<= value u999)
                (concat 
                    (concat
                        (unwrap-panic (element-at "0123456789" (/ value u100)))
                        (unwrap-panic (element-at "0123456789" (mod (/ value u10) u10)))
                    )
                    (unwrap-panic (element-at "0123456789" (mod value u10)))
                )
                ;; For numbers > 999, just return the string representation of the number modulo 1000
                (concat 
                    (concat
                        (unwrap-panic (element-at "0123456789" (/ (mod value u1000) u100)))
                        (unwrap-panic (element-at "0123456789" (mod (/ (mod value u1000) u10) u10)))
                    )
                    (unwrap-panic (element-at "0123456789" (mod (mod value u1000) u10)))
                )
            )
        )
    )
)